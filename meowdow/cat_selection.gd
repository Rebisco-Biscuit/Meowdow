extends Control

var CAT_SCENE = preload("res://OrangeCat.tscn")
#var MAP_SCENE = preload("res://MAPtest.tscn")
var MAP_SCENE = preload("res://MAP2.tscn")

func _on_orange_select_pressed():
	CAT_SCENE = preload("res://OrangeCat.tscn")
	select_and_spawn("orange")

func _on_black_select_pressed():
	CAT_SCENE = preload("res://BlackCat.tscn")
	select_and_spawn("black")

func _on_white_select_pressed():
	CAT_SCENE = preload("res://WhiteCat.tscn")
	select_and_spawn("white")


func select_and_spawn(color_string):

	# 1. Load the map
	var map = MAP_SCENE.instantiate()
	get_tree().root.add_child(map)
	get_tree().current_scene = map

	# 2. Spawn the cat scene
	var cat = CAT_SCENE.instantiate()
	map.add_child(cat)

	# 3. Get the ACTUAL body (based on your structure)
	var cat_body = cat.get_node("CharacterBody2D")
	cat_body.cat_type = color_string

	# 4. Spawn at TILE (24,15)
	var tilemap = map.get_node("TileMapLayer")
	var tile_pos = Vector2i(39, 26)

	var world_pos = tilemap.map_to_local(tile_pos)
	var tile_size = tilemap.tile_set.tile_size

	cat.global_position = world_pos + Vector2(tile_size.x, tile_size.y) / 2

	# 5. Camera (correct path now, finally)
	var camera = cat_body.get_node("Camera2D")
	camera.enabled = true
	camera.zoom = Vector2(4, 4) # adjust to taste (1.5–3)

	# optional: smoother camera (feels nicer)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0

	# 6. Remove menu
	queue_free()
