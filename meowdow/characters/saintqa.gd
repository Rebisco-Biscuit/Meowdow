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

var seed_scenes = [
	preload("res://inventory/collectables/carrot.tscn"),
	#preload("res://inventory/collectables/corn_seed.tscn"),
	#preload("res://inventory/collectables/beetroot_seed.tscn"),
	#preload("res://inventory/collectables/berries_seed.tscn"),
	#preload("res://inventory/collectables/tomato_seed.tscn"),
	#preload("res://inventory/collectables/strawberry_seed.tscn"),
]

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
		for seed_scene in seed_scenes:
			give_seed(seed_scene)

# --- Generic seed giver ---
func give_seed(seed_scene: PackedScene):
	if player == null:
		return

	var inventory = player.inventory
	if inventory == null:
		print("No inventory found on player.")
		return

	var seed_item = seed_scene.instantiate()

	if seed_item.get("item") != null:
		for i in range(100):
			inventory.insert(seed_item.item)
		print(seed_item.item.name, " added to inventory!")
	else:
		print("Could not find item resource on seed scene.")

	seed_item.queue_free()

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
