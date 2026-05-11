extends TileMap

@onready var tile_layer: TileMapLayer = $TileMapLayer2
@onready var catnip_label: Label = $CanvasLayer/CatnipLabel

const GLOW_ATLAS_COORDS = [Vector2i(18, 3), Vector2i(18, 4)]
const SOURCE_ID = 0
const ALT_ID = 0
const FACING_DISTANCE = 15.0

var planted_cells: Dictionary = {}
var crop_scene = preload("res://crops/Crop.tscn")
var hotbar_node

var glow_sprite: Sprite2D
var currently_glowing_cell: Vector2i = Vector2i(-9999, -9999)
var cat_body: CharacterBody2D

func _ready():
	get_tree().paused = false
	
	var in_game_menu = preload("res://in_gamemenu.tscn").instantiate()
	$CanvasLayer.add_child(in_game_menu)
	
	hotbar_node = preload("res://inventory/hotbar.tscn").instantiate()
	$CanvasLayer.add_child(hotbar_node)
	
	var playerCharPath = GlobalData.playerCharPath
	var playerNode = load(playerCharPath).instantiate()
	add_child(playerNode)

	if GlobalData.last_position != Vector2.ZERO:
		playerNode.global_position = GlobalData.last_position
	else:
		playerNode.global_position = $playerSpawnPoint.global_position

	# --- CAT TYPE SETUP ---
	cat_body = playerNode.get_node("CharacterBody2D")
	cat_body.cat_type = GlobalData.selectedCatType

	# --- CAMERA SETUP ---
	var camera = cat_body.get_node("Camera2D")
	camera.enabled = true
	camera.zoom = Vector2(4.5, 4.5)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0

	# --- INVENTORY RESTORE --- (after cat_body is assigned)
	if GlobalData.saved_slots.size() > 0:
		var inventory: Inv = cat_body.inventory
		for i in range(min(GlobalData.saved_slots.size(), inventory.slots.size())):
			var data = GlobalData.saved_slots[i]
			if data["path"] != "null":
				var item = load(data["path"]) as InvItem
				if item:
					inventory.slots[i].item = item
					inventory.slots[i].amount = data["amount"]
		inventory.updated.emit()
		GlobalData.saved_slots.clear()

	# --- GLOW SETUP ---
	glow_sprite = Sprite2D.new()

	var img = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	glow_sprite.texture = ImageTexture.create_from_image(img)

	glow_sprite.scale = Vector2(16, 16)
	glow_sprite.modulate = Color(1.0, 0.9, 0.3, 0.5)
	glow_sprite.visible = false
	glow_sprite.centered = false
	add_child(glow_sprite)

# --- CROP RESTORE ---
	for cell in GlobalData.saved_crops.keys():
		var info = GlobalData.saved_crops[cell]
		var crop_data = load(info["data_path"]) as CropData
		if crop_data == null:
			continue
		var crop = crop_scene.instantiate()
		crop.data = crop_data
		crop.stage = info["stage"]
		var tile_pos = tile_layer.to_global(tile_layer.map_to_local(cell))
		crop.global_position = tile_pos
		add_child(crop)
		planted_cells[cell] = crop

	update_catnip_label()
# --- try plant ---
func _try_interact():
	if not glow_sprite.visible:
		return

	var cell = currently_glowing_cell

	if planted_cells.has(cell):
		var crop = planted_cells[cell]
		if crop.stage == crop.data.stage_rects.size():
			crop.harvest()
			planted_cells.erase(cell)
			GlobalData.saved_crops.erase(cell)  # ← remove from save
		else:
			print("Not ready! Stage: ", crop.stage)
		return

	var hotbar = hotbar_node
	var selected_item: InvItem = hotbar.get_selected_item()

	if selected_item == null or selected_item.crop_data == null:
		print("No seed selected!")
		return

	var inv: Inv = cat_body.inventory
	inv.remove(selected_item)

	var crop = crop_scene.instantiate()
	crop.data = selected_item.crop_data
	var tile_pos = tile_layer.to_global(tile_layer.map_to_local(cell))
	crop.global_position = tile_pos
	add_child(crop)
	planted_cells[cell] = crop

	# ← save crop to GlobalData
	GlobalData.saved_crops[cell] = {
		"data_path": selected_item.crop_data.resource_path,
		"stage": 1
	}

func _process(_delta):
	if cat_body == null:
		return
	
	GlobalData.last_position = cat_body.global_position
	
	for cell in planted_cells.keys():
		GlobalData.saved_crops[cell]["stage"] = planted_cells[cell].stage	
	
	if Input.is_action_just_pressed("farm"):
		_try_interact()

	var cell = tile_layer.local_to_map(tile_layer.to_local(cat_body.global_position))
	_update_glow(cell)

	# Pulse alpha when visible
	if glow_sprite.visible:
		glow_sprite.modulate.a = 0.3 + sin(Time.get_ticks_msec() * 0.005) * 0.2
		
	update_catnip_label()

func _last_dir_to_vector(dir: String) -> Vector2:
	var v = Vector2.ZERO
	if "a" in dir: v.x -= 1
	if "d" in dir: v.x += 1
	if "w" in dir: v.y -= 1
	if "s" in dir: v.y += 1
	return v.normalized()

func _update_glow(cell: Vector2i):
	if cell == currently_glowing_cell:
		return

	currently_glowing_cell = cell

	var source_id = tile_layer.get_cell_source_id(cell)
	var atlas_coord = tile_layer.get_cell_atlas_coords(cell)
	var alt = tile_layer.get_cell_alternative_tile(cell)

	if source_id == SOURCE_ID and alt == ALT_ID and atlas_coord in GLOW_ATLAS_COORDS:
		var tile_pos = tile_layer.to_global(tile_layer.map_to_local(cell))
		glow_sprite.global_position = tile_pos - Vector2(8, 8)  # offset by half tile (16/2)
		glow_sprite.visible = true
	else:
		glow_sprite.visible = false

func update_catnip_label():
	catnip_label.text = "$ " + str(GlobalData.catnips)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GlobalData.create_save()
