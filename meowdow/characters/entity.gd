extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var prompt = $Prompt

var player = null
var player_inside = false

var idle_timer := 0.0
var idle_interval := 5.0
var is_talking = false

var bg_scene = preload("res://DialogueBackground.tscn")

func _ready():
	prompt.visible = false
	randomize()
	# Entity only appears after defeating Echofall
	visible = GlobalData.quest_step >= 20

func _process(delta):
	visible = GlobalData.quest_step >= 20

	if prompt.visible:
		prompt.position.y = -5 + sin(Time.get_ticks_msec() * 0.005) * 3

	idle_timer += delta
	if idle_timer >= idle_interval:
		sprite.play("default")
		idle_timer = 0.0
		idle_interval = randf_range(4.0, 7.0)

	if player and not is_talking and Input.is_action_just_pressed("interact"):
		if GlobalData.quest_step == 20:
			start_dialogue()

func start_dialogue():
	is_talking = true
	prompt.visible = false

	var bg = bg_scene.instantiate()
	get_tree().root.add_child(bg)

	GlobalData.sync_to_dialogic()
	var dialog = Dialogic.start("res://Timelines/towns/Entitalks/Entitalks.dtl")
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in dialog.get_children():
		child.process_mode = Node.PROCESS_MODE_ALWAYS

	Dialogic.timeline_ended.connect(func():
		GlobalData.sync_from_dialogic()
		is_talking = false
		bg.queue_free()

		if GlobalData.entity_choice == true:
			# Give Seed of Rhomato (tomato seed)
			var inventory = GlobalData.get_player_inventory()
			if inventory:
				var seed = preload("res://inventory/collectables/tomato_seed.tscn").instantiate()
				if seed.get("item") != null:
					inventory.insert(seed.item)
				seed.queue_free()

			# Teleport player back to Rhollow spawn
			var tree = Engine.get_main_loop() as SceneTree
			var cat_body = tree.get_first_node_in_group("player")
			if cat_body:
				cat_body.global_position = get_tree().current_scene.get_node("playerSpawnPoint").global_position

			GlobalData.quest_step = 22
			GlobalData.create_save()
			print("Rewrite path chosen! Plant the Seed of Rhomato.")
		else:
			# Finish the story
			GlobalData.quest_step = 24  # story complete
			GlobalData.create_save()
			print("Story finished!")

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
