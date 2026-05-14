extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var prompt = $Prompt

var player = null
var player_inside = false

# --- Idle animation ---
var idle_timer := 0.0
var idle_interval := 5.0

var is_talking = false
var bg_scene = preload("res://DialogueBackground.tscn")

func _ready():
	prompt.visible = false
	randomize()

func _process(delta):
	# --- Prompt animation ---
	if prompt.visible:
		prompt.position.y = -5 + sin(Time.get_ticks_msec() * 0.005) * 3

	# --- Idle animation ---
	idle_timer += delta
	if idle_timer >= idle_interval:
		sprite.play("default")
		idle_timer = 0.0
		idle_interval = randf_range(4.0, 7.0)

	# --- Interaction ---
	if player and not is_talking and Input.is_action_just_pressed("interact"):
		start_dialogue()

func start_dialogue():
	is_talking = true
	prompt.visible = false

	var bg = bg_scene.instantiate()
	get_tree().root.add_child(bg)

	GlobalData.sync_to_dialogic()
	var dialog = Dialogic.start("res://Timelines/towns/Aubrialis(Town2/Thaaw.dtl")
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in dialog.get_children():
		child.process_mode = Node.PROCESS_MODE_ALWAYS

	Dialogic.timeline_ended.connect(func():
		GlobalData.sync_from_dialogic()
		is_talking = false
		bg.queue_free()

		# Quest step 10 → Thaw gives mission
		if GlobalData.quest_step == 10:
			GlobalData.quest_step = 11  # next: plant 150 frostbell + 150 snowbloom
			GlobalData.create_save()

		# Quest step 11 → crops done, Thaw gives thawbloom + image
		elif GlobalData.quest_step == 11 and _crops_done():
			GlobalData.quest_step = 12  # next: talk to Frostcribe again
			_give_thawbloom()
			GlobalData.create_save()

		prompt.visible = player_inside
	, CONNECT_ONE_SHOT)

func _crops_done() -> bool:
	return GlobalData.frostbell_count >= 150 and GlobalData.snowbloom_count >= 150

func _give_thawbloom():
	# Give thawbloom (berries) as reward
	var thawbloom = preload("res://inventory/collectables/berries.tscn").instantiate()
	if player and player.inventory and thawbloom.get("item") != null:
		player.inventory.insert(thawbloom.item)
		print("Thawbloom given!")
	thawbloom.queue_free()

func _on_interaction_zone_body_entered(body):
	if body is CharacterBody2D:
		player_inside = true
		player = body
		if not is_talking:
			prompt.visible = true

func _on_interaction_zone_body_exited(body):
	if body is CharacterBody2D:
		player_inside = false
		player = null
		prompt.visible = false
