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
var carrot_seed_scene = preload("res://inventory/collectables/carrot_seed.tscn")


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
		give_carrot_seed()


# --- Give carrot seed to player inventory ---
func give_carrot_seed():
	var cat_body = player  # player is already the CharacterBody2D
	if cat_body == null:
		return

	var inventory = cat_body.inventory
	if inventory == null:
		print("No inventory found on player.")
		return

	var seed_item = carrot_seed_scene.instantiate()
	
	# Find the item resource from the collectable
	if seed_item.has_method("get_item"):
		inventory.insert(seed_item.get_item())
	elif seed_item.get("item") != null:
		inventory.insert(seed_item.item)
	else:
		print("Could not find item resource on carrot_seed scene.")

	seed_item.queue_free()
	print("Carrot seed added to inventory!")


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
