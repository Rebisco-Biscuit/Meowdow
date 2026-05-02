extends Area2D

@export var maps = {
	"Vinalore": "res://Vinalore.tscn",
	"Aubrialis": "res://Aubrialis.tscn"
}

var player_inside = false
var player = null

func _on_body_entered(body):
	if body is CharacterBody2D:
		player_inside = true
		player = body

func _on_body_exited(body):
	if body is CharacterBody2D:
		player_inside = false
		player = null

func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		open_map_menu()


func open_map_menu():
	var menu = preload("res://map_menu.tscn").instantiate()
	get_tree().root.add_child(menu)

	if player:
		var screen_pos = get_viewport().get_canvas_transform() * player.global_position
		menu.position = screen_pos + Vector2(180, 60)

	menu.setup(maps, get_tree().current_scene.name, self)
