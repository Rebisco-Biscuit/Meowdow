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
	# Glow only appears after guide talk
	visible = GlobalData.quest_step >= 16

func _process(delta):
	# Show Glow only when quest step is right
	visible = GlobalData.quest_step >= 16

	if prompt.visible:
		prompt.position.y = -5 + sin(Time.get_ticks_msec() * 0.005) * 3

	idle_timer += delta
	if idle_timer >= idle_interval:
		sprite.play("default")
		idle_timer = 0.0
		idle_interval = randf_range(4.0, 7.0)

	if player and not is_talking and Input.is_action_just_pressed("interact"):
		if GlobalData.quest_step >= 16:
			start_dialogue()

func start_dialogue():
	is_talking = true
	prompt.visible = false

	var bg = bg_scene.instantiate()
	get_tree().root.add_child(bg)

	GlobalData.sync_to_dialogic()
	var dialog = Dialogic.start("res://Timelines/towns/Rhollow(Town3/Glow.dtl")
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in dialog.get_children():
		child.process_mode = Node.PROCESS_MODE_ALWAYS

	Dialogic.timeline_ended.connect(func():
		GlobalData.sync_from_dialogic()
		is_talking = false
		bg.queue_free()

		if GlobalData.quest_step == 17:
			GlobalData.quest_step = 18  # next: plant Gloomberries
			GlobalData.create_save()

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
