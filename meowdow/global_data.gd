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
var has_received_starter_catnips: bool = false

# --- QUEST SYSTEM ---
var quest_step: int = 0
var gigglerain_count: int = 0
var wheepingwheat_count: int = 0
var aubrialis_unlocked: bool = false
var rhollow_unlocked: bool = false
var frostbell_count: int = 0
var snowbloom_count: int = 0

# --- CURSOR ---
var arrow
var click
var arrow_scaled: ImageTexture
var click_scaled: ImageTexture

var ui_sfx_player: AudioStreamPlayer

func _ready():
	load_cursor_by_cat()
	Input.set_custom_mouse_cursor(arrow_scaled)

func load_cursor_by_cat():
	var color = selectedCatType
	print(color)
	# fallback in case nothing is set (because humans forget things)
	if color == "":
		color = "white"

	var arrow_path = "res://assets/arrow_%s.png" % color
	var click_path = "res://assets/arrowclick_%s.png" % color

	arrow = load(arrow_path)
	click = load(click_path)

	arrow_scaled = scale_cursor(arrow, 4)
	click_scaled = scale_cursor(click, 4)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			Input.set_custom_mouse_cursor(click_scaled)
		else:
			Input.set_custom_mouse_cursor(arrow_scaled)

func scale_cursor(texture: Texture2D, scale: int) -> ImageTexture:
	var image = texture.get_image()
	var new_size = image.get_size() * scale
	image.resize(new_size.x, new_size.y, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)

# --- DIALOGIC SYNC ---
func sync_to_dialogic():
	Dialogic.VAR.Thaw.gigglerain_count = gigglerain_count
	Dialogic.VAR.Thaw.wheepingwheat_count = wheepingwheat_count  # fixed: was .wheepingwheat
	Dialogic.VAR.Thaw.quest_started = quest_step > 0
	Dialogic.VAR.Thaw.town1event = quest_step >= 4
	Dialogic.VAR.Thaw.town1event2 = quest_step >= 7
	Dialogic.VAR.Thaw.event_done = aubrialis_unlocked
	Dialogic.VAR.Thaw.frostbell_count = frostbell_count
	Dialogic.VAR.Thaw.snowbloom_count = snowbloom_count

func sync_from_dialogic():
	gigglerain_count = int(Dialogic.VAR.Thaw.gigglerain_count)
	wheepingwheat_count = int(Dialogic.VAR.Thaw.wheepingwheat_count)
	frostbell_count = int(Dialogic.VAR.Thaw.frostbell_count)
	snowbloom_count = int(Dialogic.VAR.Thaw.snowbloom_count)

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

	# Save quest state
	file.store_line(str(quest_step))
	file.store_line(str(gigglerain_count))
	file.store_line(str(wheepingwheat_count))
	file.store_line(str(aubrialis_unlocked))
	file.store_line(str(rhollow_unlocked))
	file.store_line(str(frostbell_count))
	file.store_line(str(snowbloom_count))

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

	load_cursor_by_cat()
	Input.set_custom_mouse_cursor(arrow_scaled)

	# Load quest state
	quest_step = int(file.get_line())
	gigglerain_count = int(file.get_line())
	wheepingwheat_count = int(file.get_line())
	aubrialis_unlocked = file.get_line() == "true"
	rhollow_unlocked = file.get_line() == "true"  # fixed: was missing
	frostbell_count = int(file.get_line())
	snowbloom_count = int(file.get_line())

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
