extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var prompt = $Prompt

var player = null
var player_inside = false

# --- Idle animation ---
var idle_timer := 0.0
var idle_interval := 5.0

# --- Dialogue state ---
var has_talked = false
var is_talking = false

var bg_scene = preload("res://startdialogue.tscn")

func _ready():
	prompt.visible = false
	randomize()

	# Auto-trigger first dialogue if brand new game
	# (called from selection_screen after scene loads)

# --- Interaction zone signals ---
func _on_interaction_zone_body_entered(body):
	if body is CharacterBody2D:
		player_inside = true
		player = body
		if not is_talking:
			prompt.visible = true

func _on_interaction_zone_body_exited(body):
	if body is CharacterBody2D:
		player_inside = false  # fixed: was true
		player = null
		prompt.visible = false

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
		var to_npc = (global_position - player.global_position).normalized()
		var player_dir = player.velocity.normalized()

		if player.velocity.length() == 0 or player_dir.dot(to_npc) > 0.5:
			talk()

# --- Dialogue logic ---
func talk():
	is_talking = true
	prompt.visible = false

	if not has_talked:
		has_talked = true
		start_dialogue("res://Timelines/towns/Town1_Start.dtl")
	else:
		start_dialogue("res://Timelines/towns/Town1_Repeat.dtl")

# --- Dialogic integration ---
func start_dialogue(dialogue_path):
	var cached_player = player

	cached_player.set_process(false)
	cached_player.set_physics_process(false)
	cached_player.set_process_input(false)

	var bg = bg_scene.instantiate()
	get_tree().root.add_child(bg)

	var dialog = Dialogic.start(dialogue_path)
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS

	for child in dialog.get_children():
		child.process_mode = Node.PROCESS_MODE_ALWAYS

	Dialogic.timeline_ended.connect(func():
		is_talking = false

		cached_player.set_process(true)
		cached_player.set_physics_process(true)
		cached_player.set_process_input(true)

		if GlobalData.quest_step == 0:
			GlobalData.quest_step = 1  # next: find Luna
			GlobalData.create_save()

		if player_inside:
			prompt.visible = true

		bg.queue_free()
	, CONNECT_ONE_SHOT)
