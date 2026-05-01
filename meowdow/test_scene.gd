extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var playerCharPath = GlobalData.playerCharPath
	var playerNode = load(playerCharPath).instantiate()
	add_child(playerNode)
	playerNode.global_position = $playerSpawnPoint.global_position

	var sprite = playerNode.find_child("", true, false)
	
	for child in playerNode.get_children():
		print(child.name)  # DEBUG: see actual node names

	sprite = playerNode.find_child("AnimatedSprite2D", true, false)

	if sprite:
		sprite.cat_type = GlobalData.selectedCatType
	else:
		print("Sprite not found!")
