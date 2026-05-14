extends Control

var maps
var map_locks
var current_map
var portal_ref

func setup(map_dict, locks_dict, current, portal):
	maps = map_dict
	map_locks = locks_dict
	current_map = current
	portal_ref = portal

	for button in $VBoxContainer.get_children():
		var map_name = button.text

		if button.pressed.is_connected(teleport):
			button.pressed.disconnect(teleport)

		if map_name == current_map:
			button.disabled = true
			button.tooltip_text = "You are here"
		elif map_locks.has(map_name):
			# Check if the unlock flag is true in GlobalData
			var flag = map_locks[map_name]
			var is_unlocked = GlobalData.get(flag)
			if not is_unlocked:
				button.disabled = true
				button.tooltip_text = "🔒 Locked"
			else:
				button.disabled = false
				button.tooltip_text = ""
				button.pressed.connect(teleport.bind(map_name))
		else:
			button.disabled = false
			button.tooltip_text = ""
			button.pressed.connect(teleport.bind(map_name))

func teleport(map_name):
	var scene_path = maps[map_name]
	portal_ref.travel_to(scene_path)
	queue_free()
