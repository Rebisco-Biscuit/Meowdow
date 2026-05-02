extends Area2D

@export var item: InvItem

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody2D:
		collect(body)

func collect(body):
	if body.inventory:
		body.inventory.insert(item)
	else:
		print("Player has no inventory!")

	queue_free()
