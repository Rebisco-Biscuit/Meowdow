extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var prompt = $Prompt

var player = null
var player_inside = false

# --- Idle animation ---
var is_talking = false

func _ready():
	prompt.visible = false

func _process(delta):
	# --- Prompt animation ---
	if prompt.visible:
		prompt.position.y = -5 + sin(Time.get_ticks_msec() * 0.005) * 3

	# --- Idle animation ---
	sprite.play("default")

	# --- Interaction ---
	if player and not is_talking and Input.is_action_just_pressed("interact"):
		start_typing_game()

func start_typing_game():
	is_talking = true
	prompt.visible = false
	GlobalData.dev_name = "Aubrien"	
	GlobalData.dev_wpm = 80
	GlobalData.dev_sprite_frames = sprite.sprite_frames
	GlobalData.last_map = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://typing_game.tscn")

func _on_interaction_zone_body_entered(body):
	if body is CharacterBody2D:
		player = body
		player_inside = true
		if not is_talking:
			prompt.visible = true

func _on_interaction_zone_body_exited(body):
	if body is CharacterBody2D:
		player = null
		player_inside = false
		prompt.visible = false
