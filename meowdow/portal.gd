extends Area2D

@export var maps = {
	"Vinalore": "res://Vinalore.tscn",
	"Aubrialis": "res://Aubrialis.tscn",
	"Rhollow": "res://Rhollow.tscn"
}

# Which maps require which unlock flag
var map_locks = {
	"Aubrialis": "aubrialis_unlocked",
	"Rhollow": "rhollow_unlocked"
}

var player_inside = false
var menu_instance = null
var player = null
@onready var prompt = $Prompt

func _on_body_entered(body):
	if body is CharacterBody2D:
		player_inside = true
		player = body
		prompt.visible = true

func _on_body_exited(body):
	if body is CharacterBody2D:
		player_inside = false
		player = null
		prompt.visible = false
		close_map_menu()

func _process(_delta):
	if prompt.visible:
		prompt.position.y = -10 + sin(Time.get_ticks_msec() * 0.005) * 3

	if player_inside and Input.is_action_just_pressed("interact"):
		if menu_instance == null:
			open_map_menu()
		else:
			close_map_menu()

func open_map_menu():
	menu_instance = preload("res://map_menu.tscn").instantiate()
	get_tree().root.add_child(menu_instance)
	var camera = get_viewport().get_camera_2d()
	get_tree().paused = true
	var screen_pos = camera.get_screen_center_position() + (global_position - camera.global_position)
	menu_instance.position = screen_pos + Vector2(20, -20)
	menu_instance.setup(maps, map_locks, get_tree().current_scene.name, self)

func close_map_menu():
	if menu_instance:
		get_tree().paused = false
		menu_instance.queue_free()
		menu_instance = null

func travel_to(scene_path: String):
	close_map_menu()
	GlobalData.last_position = Vector2.ZERO
	GlobalData.last_map = scene_path
	GlobalData.create_save()
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)
