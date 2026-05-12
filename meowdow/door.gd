extends Node2D

@onready var prompt = $Prompt
var player = null
# Called when the node enters the scene tree for the first time.
func _ready():
	prompt.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if prompt.visible:
		prompt.position.y = -5 + sin(Time.get_ticks_msec() * 0.005) * 3

	if player and Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file("res://rhollow.tscn")

func _on_interaction_zone_body_entered(body):
	if body is CharacterBody2D:
		player = body
		prompt.visible = true


func _on_interaction_zone_body_exited(body):
	if body is CharacterBody2D:
		player = null
		prompt.visible = false
