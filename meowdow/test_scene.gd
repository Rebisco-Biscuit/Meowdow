extends Node2D

func _ready():
	var playerCharPath = GlobalData.playerCharPath
	var playerNode = load(playerCharPath).instantiate()
	add_child(playerNode)

	playerNode.global_position = $playerSpawnPoint.global_position

	# --- CAT TYPE SETUP ---
	var cat_body = playerNode.get_node("CharacterBody2D")
	cat_body.cat_type = GlobalData.selectedCatType

	# --- CAMERA SETUP ---
	var camera = cat_body.get_node("Camera2D")
	camera.enabled = true
	camera.zoom = Vector2(4, 4)

	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
