extends Node2D

@onready var prompt = $Prompt
@onready var area = $InteractionZone

var player = null
var is_talking = false
var bg_scene = preload("res://DialogueBackground.tscn")

func _ready():
	prompt.visible = false

func _process(_delta):
	# --- Prompt animation ---
	if prompt.visible:
		prompt.position.y = -5 + sin(Time.get_ticks_msec() * 0.005) * 3

	# --- Interaction ---
	if player and not is_talking and Input.is_action_just_pressed("interact"):
		start_dialogue()

func start_dialogue():
	is_talking = true
	prompt.visible = false

	print(GlobalData.wheepingwheat_count)
	var bg = bg_scene.instantiate()
	get_tree().root.add_child(bg)

	# Sync GlobalData → Dialogic before starting
	GlobalData.sync_to_dialogic()

	var dialog = Dialogic.start("res://Timelines/towns/Vinalore(Town1/Keeper.dtl")
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in dialog.get_children():
		child.process_mode = Node.PROCESS_MODE_ALWAYS

	Dialogic.timeline_ended.connect(func():
		# Sync Dialogic → GlobalData after ending		
		GlobalData.sync_from_dialogic()

		is_talking = false
		bg.queue_free()

		if GlobalData.quest_step == 7:
			if GlobalData.old_jerry_choice == true:
				GlobalData.aubrialis_unlocked = true
				GlobalData.quest_step = 8
			GlobalData.create_save()
			print("Aubrialis unlocked!")

		prompt.visible = player != null
	, CONNECT_ONE_SHOT)

func _on_interaction_zone_body_entered(body):
	if body is CharacterBody2D:
		player = body
		if not is_talking:
			prompt.visible = true

func _on_interaction_zone_body_exited(body):
	if body is CharacterBody2D:
		player = null
		prompt.visible = false
