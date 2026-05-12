extends Node

var playerCharPath: String = ""
var selectedCatType: String = ""
var catnips: int = 0
const SAVE_PATH = "user://save.dat"
var has_save: bool = false
var last_position: Vector2 = Vector2.ZERO
var last_map: String = "res://Vinalore.tscn"
var saved_slots: Array = []
var saved_crops: Dictionary = {}
var current_map: String = ""

func check_save():
	has_save = FileAccess.file_exists(SAVE_PATH)

func create_save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_line(selectedCatType)
	file.store_line(playerCharPath)
	file.store_line(str(last_position.x))
	file.store_line(str(last_position.y))
	file.store_line(str(catnips))
	file.store_line(last_map)

	# Save inventory
	var inventory = get_player_inventory()
	if inventory:
		for slot in inventory.slots:
			if slot.item != null and slot.item.resource_path != "":
				file.store_line(slot.item.resource_path)
				file.store_line(str(slot.amount))
			else:
				file.store_line("null")
				file.store_line("0")

	# Save crops
	file.store_line("---crops---")
	for key in saved_crops.keys():
		var crop_info = saved_crops[key]
		file.store_line(key)
		file.store_line(crop_info["data_path"])
		file.store_line(str(crop_info["stage"]))
		file.store_line(crop_info["map"])
		file.store_line(str(crop_info["cell"].x) + "," + str(crop_info["cell"].y))

	file.close()
	has_save = true

func load_save():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	selectedCatType = file.get_line()
	playerCharPath = file.get_line()
	last_position.x = float(file.get_line())
	last_position.y = float(file.get_line())
	catnips = int(file.get_line())
	last_map = file.get_line()

	# Load inventory and crops
	saved_slots.clear()
	saved_crops.clear()
	var reading_crops = false
	while not file.eof_reached():
		var line = file.get_line()
		if line == "---crops---":
			reading_crops = true
			continue
		if reading_crops:
			if line == "":
				continue
			var key = line
			var data_path = file.get_line()
			var stage = int(file.get_line())
			var map = file.get_line()
			var cell_parts = file.get_line().split(",")
			var cell = Vector2i(int(cell_parts[0]), int(cell_parts[1]))
			saved_crops[key] = {
				"data_path": data_path,
				"stage": stage,
				"map": map,
				"cell": cell
			}
		else:
			var path = line
			var amount = int(file.get_line())
			saved_slots.append({"path": path, "amount": amount})
	file.close()

func get_player_inventory() -> Inv:
	var tree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var cat_body = tree.get_first_node_in_group("player")
	if cat_body == null:
		return null
	return cat_body.inventory
