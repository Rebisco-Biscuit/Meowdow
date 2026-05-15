extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var prompt = $Prompt

var player = null
var player_inside = false

# --- Idle animation ---
var idle_timer := 0.0
var idle_interval := 5.0

# --- Dialogue state ---
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
		# Only interactable after Frostcribe first visit
		if GlobalData.quest_step >= 10:
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
		print(GlobalData.quest_step)
		is_talking = false
		bg.queue_free()

		# First visit → give mission to farm
		if GlobalData.quest_step == 11:
			GlobalData.quest_step = 12  # next: plant frostbell + snowbloom
			GlobalData.create_save()

		if GlobalData.quest_step == 13:
			var berry_item   = preload("res://inventory/items/berries.tres")
			var beetroot_item = preload("res://inventory/items/beetroot.tres")

			if player and player.inventory:
				var berry_count    = player.inventory.get_item_count(berry_item)
				var beetroot_count = player.inventory.get_item_count(beetroot_item)

				if berry_count >= 150 and beetroot_count >= 150:
					for i in 150:
						player.inventory.remove(berry_item)
					for i in 150:
						player.inventory.remove(beetroot_item)

					print("Berries and beetroot taken!")

					GlobalData.quest_step = 14  # Talk to frostcribe
					GlobalData.create_save()
				else:
					print("Not enough berries or beetroot!")

		prompt.visible = player_inside
	, CONNECT_ONE_SHOT)

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
