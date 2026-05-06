extends CharacterBody2D

@onready var prompt = $Prompt
@onready var area = $InteractionZone

var player = null

func _ready():
	prompt.visible = false

func _on_interaction_zone_body_entered(body):
	if body is CharacterBody2D:
		player = body
		prompt.visible = true

func _on_interaction_zone_body_exited(body):
	if body is CharacterBody2D:
		player = null
		prompt.visible = false

func _process(_delta):
	if player and Input.is_action_just_pressed("interact"):
		talk()
		
func talk():
	print("NPC: meow. go touch grass.")		
