extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var playerCharPath = GlobalData.playerCharPath
	var playerNode = load(playerCharPath).instantiate()
	add_child(playerNode)
	playerNode.global_position = $playerSpawnPoint.global_position
