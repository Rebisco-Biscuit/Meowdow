extends TileMap

const MAP_NAME = "dungeon"
var hotbar_node
var cat_body = CharacterBody2D
@onready var posa = $Entity
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	GlobalData.current_map = MAP_NAME

	var in_game_menu = preload("res://in_gamemenu.tscn").instantiate()
	$CanvasLayer.add_child(in_game_menu)

	hotbar_node = preload("res://inventory/hotbar.tscn").instantiate()
	$CanvasLayer.add_child(hotbar_node)

	var quest_panel = preload("res://quest_panel.tscn").instantiate()
	$CanvasLayer.add_child(quest_panel)	
	
	if GlobalData.echofall_defeated == true and GlobalData.quest_step == 21:
		posa.visible = true

	var playerCharPath = GlobalData.playerCharPath
	var playerNode = load(playerCharPath).instantiate()
	add_child(playerNode)

	if GlobalData.last_map == "res://dungeon.tscn" and GlobalData.last_position != Vector2.ZERO:
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

	# --- INVENTORY RESTORE ---
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
