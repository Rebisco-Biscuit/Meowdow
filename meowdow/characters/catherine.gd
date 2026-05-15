extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var prompt = $Prompt

var player = null

var idle_timer := 0.0
var idle_interval := 5.0

func _ready():
	prompt.visible = false
	randomize()
	print("[CATHERINE] Ready")


func _process(delta):

	if prompt.visible:
		prompt.position.y = -5 + sin(Time.get_ticks_msec() * 0.005) * 3

	idle_timer += delta
	if idle_timer >= idle_interval:
		sprite.play("default")
		idle_timer = 0.0
		idle_interval = randf_range(4.0, 7.0)

	if player and Input.is_action_just_pressed("interact"):
		open_shop()


func open_shop():

	print("[CATHERINE] Opening shop")

	if player == null:
		print("[CATHERINE] No player found")
		return

	var shop_scene = preload("res://sell_ui.tscn")

	if shop_scene == null:
		print("[CATHERINE] Failed to load shop scene")
		return

	var shop_ui = shop_scene.instantiate()

	if shop_ui == null:
		print("[CATHERINE] Failed to instantiate shop UI")
		return

	# Add to scene FIRST so @onready vars are initialized before the inventory setter fires
	get_tree().current_scene.add_child(shop_ui)
	shop_ui.inventory = player.inventory

	print("[CATHERINE] Shop opened")


func _on_interaction_zone_body_entered(body):
	if body is CharacterBody2D:
		player = body
		prompt.visible = true
		print("[CATHERINE] Player entered")


func _on_interaction_zone_body_exited(body):
	if body == player:
		player = null
		prompt.visible = false
		print("[CATHERINE] Player left")
