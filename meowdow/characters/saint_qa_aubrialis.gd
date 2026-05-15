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
		complete_quest2()

# --- Demo: skip to end of quest 1 ---
func complete_quest2():
	if player == null:
		return

	var inventory = player.inventory
	if inventory == null:
		print("No inventory found on player.")
		return

	# --- Max out all quest counters ---
	GlobalData.snowbloom_count = 150
	GlobalData.frostbell_count = 150
	GlobalData.quest_step = 15
	GlobalData.aubrialis_unlocked = true
	GlobalData.rhollow_unlocked = true
	# --- Sync to Dialogic ---
	GlobalData.sync_to_dialogic()

	# --- Give some crops for testing ---
	#var berries = preload("res://inventory/collectables/berries.tscn").instantiate()
	#var beetroot = preload("res://inventory/collectables/beetroot.tscn").instantiate()
	#if berries.get("item") != null and beetroot.get("item") != null:
		#for i in range(150):
			#inventory.insert(berries.item)
			#inventory.insert(beetroot.item)
	#berries.queue_free()
	#beetroot.queue_free()

	# --- Save ---
	GlobalData.create_save()

	print("Quest 2 complete! quest_step=15, rhollow unlocked.")
	prompt.visible = false

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
