extends Control

var maps
var current_map
var portal_ref

func setup(map_dict, current, portal):
	maps = map_dict
	current_map = current
	portal_ref = portal

	get_tree().paused = true	
	
	for button in $VBoxContainer.get_children():
		var map_name = button.text

		if map_name == current_map:
			button.disabled = true
		else:
			button.disabled = false

		button.pressed.connect(Callable(self, "teleport").bind(map_name))


func teleport(map_name):
	print(map_name)
	var scene_path = maps[map_name]
	var new_map = load(scene_path).instantiate()
	
	get_tree().paused = false
	
	get_tree().root.add_child(new_map)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_map

	queue_free() # remove UI
