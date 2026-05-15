extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var prompt = $Prompt

var player = null
var bg_scene = preload("res://DialogueBackground.tscn")

# --- Idle animation ---
var idle_timer := 0.0
var idle_interval := 5.0

# --- Dialogue state ---
var is_talking = false

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

	# Sync GlobalData → Dialogic before starting
	GlobalData.sync_to_dialogic()

	var dialog = Dialogic.start("res://Timelines/towns/Vinalore(Town1/Quest.dtl")
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in dialog.get_children():
		child.process_mode = Node.PROCESS_MODE_ALWAYS

	Dialogic.timeline_ended.connect(func():
		# Sync Dialogic → GlobalData after ending
		GlobalData.sync_from_dialogic()

		is_talking = false
		bg.queue_free()

		if GlobalData.quest_step == 4:
			var carrot_item = preload("res://inventory/items/carrot.tres")

			if player and player.inventory:
				var carrot_count = player.inventory.get_item_count(carrot_item)

				if carrot_count >= 100:
					# remove() takes one at a time, so loop 100x
					for i in 100:
						player.inventory.remove(carrot_item)

					# Give corn seed
					var seed = preload("res://inventory/collectables/corn_seed.tscn").instantiate()
					player.inventory.insert(seed.item)
					seed.queue_free()

					print("Wheepingwheat seed given!")

					GlobalData.quest_step = 5
					GlobalData.create_save()
				else:
					print("Not enough carrots!")

		prompt.visible = player != null
	, CONNECT_ONE_SHOT)

# --- Interaction zone signals ---
func _on_interaction_zone_body_entered(body):
	if body is CharacterBody2D:
		player = body
		if not is_talking:
			prompt.visible = true

func _on_interaction_zone_body_exited(body):
	if body is CharacterBody2D:
		player = null
		prompt.visible = false
