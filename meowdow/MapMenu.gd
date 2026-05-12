extends Control

var maps
var current_map
var portal_ref

func setup(map_dict, current, portal):
	maps = map_dict
	current_map = current
	portal_ref = portal

	for button in $VBoxContainer.get_children():
		var map_name = button.text

		if button.pressed.is_connected(teleport):
			button.pressed.disconnect(teleport)

		if map_name == current_map:
			button.disabled = true
		else:
			button.disabled = false

		button.pressed.connect(teleport.bind(map_name))

func teleport(map_name):
	var scene_path = maps[map_name]
	portal_ref.travel_to(scene_path)
	queue_free()
