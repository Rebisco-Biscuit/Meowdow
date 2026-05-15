extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var prompt = $Prompt

var player = null
var player_inside = false

# --- Idle animation ---

var is_talking = false
var bg_scene = preload("res://DialogueBackground.tscn")

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
		print("tanginamo")

func _on_interaction_zone_body_entered(body):
	if body is CharacterBody2D:
		player = body
		if not is_talking:
			prompt.visible = true

func _on_interaction_zone_body_exited(body):
	if body is CharacterBody2D:
		player = null
		prompt.visible = false
