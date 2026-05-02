extends TileMap

var portal_scene = preload("res://portal.tscn")

func _ready():
	var portal = portal_scene.instantiate()
	add_child(portal)

	var tilemap = $TileMapLayer
	var tile_pos = Vector2i(52, 28)

	var world_pos = tilemap.map_to_local(tile_pos)
	var tile_size = tilemap.tile_set.tile_size

	portal.global_position = world_pos + Vector2(tile_size.x, tile_size.y) / 2
