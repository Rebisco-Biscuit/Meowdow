extends CharacterBody2D

@export var speed = 200
@export var inv: Inv

func _physics_process(_delta):

	var direction = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")

	velocity = direction.normalized() * speed
	move_and_slide()
