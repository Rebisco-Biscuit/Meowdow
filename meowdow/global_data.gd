extends Node

var playerCharPath: String
var selectedCatType: String
var catnips: int = 0
const SAVE_PATH = "user://save.dat"
var has_save: bool = false
var last_position: Vector2 = Vector2.ZERO
var saved_slots: Array = []
var saved_crops: Dictionary = {}

func check_save():
	has_save = FileAccess.file_exists(SAVE_PATH)

func create_save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_line(selectedCatType)
	file.store_line(playerCharPath)
	file.store_line(str(last_position.x))
	file.store_line(str(last_position.y))
	file.store_line(str(catnips))

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
	for cell in saved_crops.keys():
		var crop_info = saved_crops[cell]
		file.store_line(str(cell.x) + "," + str(cell.y))
		file.store_line(crop_info["data_path"])
		file.store_line(str(crop_info["stage"]))

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

	# Load inventory
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
			var parts = line.split(",")
			var cell = Vector2i(int(parts[0]), int(parts[1]))
			var data_path = file.get_line()
			var stage = int(file.get_line())
			saved_crops[cell] = {"data_path": data_path, "stage": stage}
		else:
			var path = line
			var amount = int(file.get_line())
			saved_slots.append({"path": path, "amount": amount})
	file.close()

func get_player_inventory() -> Inv:
	# Find the player inventory via scene tree
	var tree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var cat_body = tree.get_first_node_in_group("player")
	if cat_body == null:
		return null
	return cat_body.inventory
