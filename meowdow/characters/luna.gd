extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var prompt = $Prompt

var player = null

# --- Idle animation ---
var idle_timer := 0.0
var idle_interval := 5.0

# --- Dialogue state ---
var has_talked = false
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
		print("asdwasdawa")

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
