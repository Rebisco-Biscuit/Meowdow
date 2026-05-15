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
var gigglegrain_count: int = 0
var wheepingwheat_count: int = 0
var aubrialis_unlocked: bool = false
var rhollow_unlocked: bool = false
var frostbell_count: int = 0
var snowbloom_count: int = 0
var gloomberry_count: int = 0
var rhomato_count: int = 0

# --- INTERACTIONS ---
var old_jerry_choice: bool = false
var thaaw_quest_done: bool = false
var thaaw_quest_start: bool = false
var echofall_defeated: bool = false
var entity_choice: bool = false

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

# --- QUEST ADVANCEMENT ---
func on_crop_harvested(crop_name: String, amount: int):
	match crop_name:
		"carrot":
			gigglegrain_count += amount
			if gigglegrain_count >= 100 and quest_step == 3:
				quest_step = 4
				create_save()
				print("Quest step 4: Talk to Dewpaw!")

		"corn":
			wheepingwheat_count += amount
			if wheepingwheat_count >= 1 and quest_step == 6:
				quest_step = 7  # talk to Old Jerry
				create_save()
				print("Quest step 7: Talk to Old Jerry!")

		"beetroot":  # snowbloom
			snowbloom_count += amount
			_check_aubrialis_farming()

		"berries":  # frostbell
			frostbell_count += amount
			_check_aubrialis_farming()
			
		"strawberry":
			gloomberry_count += amount
			if gloomberry_count >= 1 and quest_step == 18:
				quest_step = 19
				create_save()
		
		"tomato":
			rhomato_count += amount
			if rhomato_count >= 1 and quest_step == 22:
				quest_step = 23
				create_save()

func _check_aubrialis_farming():
	if quest_step == 12 and frostbell_count >= 150 and snowbloom_count >= 150:
		quest_step = 13
		create_save()
		print("Quest step 12: Talk to Thaaw again!")

# --- DIALOGIC SYNC ---
func sync_to_dialogic():
	Dialogic.VAR.Thaw.gigglegrain_count = gigglegrain_count
	Dialogic.VAR.Thaw.wheepingwheat_count = wheepingwheat_count
	Dialogic.VAR.Thaw.quest_started = quest_step > 0
	Dialogic.VAR.Thaw.town1event = quest_step >= 4
	Dialogic.VAR.Thaw.town1event2 = quest_step >= 23
	Dialogic.VAR.Thaw.event_done = aubrialis_unlocked
	Dialogic.VAR.Thaw.frostbell_count = frostbell_count
	Dialogic.VAR.Thaw.snowbloom_count = snowbloom_count
	Dialogic.VAR.Thaw.rhomato_count = rhomato_count
	Dialogic.VAR.Thaw.gloomberry_count = gloomberry_count	
	Dialogic.VAR.Thaw.keeper_choice1 = old_jerry_choice
	Dialogic.VAR.Thaw.thaaw_quest_start = thaaw_quest_start
	Dialogic.VAR.Thaw.thaaw_quest = thaaw_quest_done
	Dialogic.VAR.Thaw.echofall_defeated = echofall_defeated
	Dialogic.VAR.Thaw.entity_cgoice = entity_choice

func sync_from_dialogic():
	gigglegrain_count = int(Dialogic.VAR.Thaw.gigglegrain_count)
	wheepingwheat_count = int(Dialogic.VAR.Thaw.wheepingwheat_count)
	frostbell_count = int(Dialogic.VAR.Thaw.frostbell_count)
	snowbloom_count = int(Dialogic.VAR.Thaw.snowbloom_count)
	gloomberry_count = int(Dialogic.VAR.Thaw.gloomberry_count)
	rhomato_count = int(Dialogic.VAR.Thaw.rhomato_count)	
	old_jerry_choice = bool(Dialogic.VAR.Thaw.keeper_choice1)
	thaaw_quest_done = bool(Dialogic.VAR.Thaw.thaaw_quest)
	thaaw_quest_start = bool(Dialogic.VAR.Thaw.thaaw_quest_start)
	echofall_defeated = bool(Dialogic.VAR.Thaw.echofall_defeated)
	entity_choice = bool(Dialogic.VAR.Thaw.entity_choice)

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
	file.store_line(str(gigglegrain_count))
	file.store_line(str(wheepingwheat_count))
	file.store_line(str(aubrialis_unlocked))
	file.store_line(str(rhollow_unlocked))
	file.store_line(str(frostbell_count))
	file.store_line(str(snowbloom_count))
	file.store_line(str(rhomato_count))
	file.store_line(str(gloomberry_count))	
	file.store_line(str(old_jerry_choice))
	file.store_line(str(thaaw_quest_done))
	file.store_line(str(thaaw_quest_start))
	file.store_line(str(echofall_defeated))
	file.store_line(str(entity_choice))

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
	gigglegrain_count = int(file.get_line())
	wheepingwheat_count = int(file.get_line())
	aubrialis_unlocked = file.get_line() == "true"
	rhollow_unlocked = file.get_line() == "true"
	frostbell_count = int(file.get_line())
	snowbloom_count = int(file.get_line())
	rhomato_count = int(file.get_line())
	gloomberry_count = int(file.get_line())	
	old_jerry_choice = (file.get_line()) == "true"
	thaaw_quest_done = (file.get_line()) == "true"	
	thaaw_quest_start = (file.get_line()) == "true"
	echofall_defeated = (file.get_line()) == "true"
	entity_choice = (file.get_line()) == "true"

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

# --- RESET DATA ---
func reset():
	playerCharPath = ""
	selectedCatType = ""
	catnips = 0
	has_save = false
	last_position = Vector2.ZERO
	last_map = "res://Vinalore.tscn"
	saved_slots = []
	saved_crops = {}
	current_map = ""
	has_received_starter_catnips = false
	quest_step = 0
	gigglegrain_count = 0
	wheepingwheat_count = 0
	aubrialis_unlocked = false
	rhollow_unlocked = false
	frostbell_count = 0
	snowbloom_count = 0
	rhomato_count = 0
	gloomberry_count = 0	
	old_jerry_choice = false
	thaaw_quest_done = false
	thaaw_quest_start = false
	echofall_defeated = false
	entity_choice = false
