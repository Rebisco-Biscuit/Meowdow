extends Control

# Preload your saved Cat Scenes (drag them from FileSystem)
var CAT_SCENE = preload("res://OrangeCat.tscn")

@onready var spawn_point = $PlayerSpawnPoint # The Marker2D where the cat will spawn

# --- SIGNAL CONNECTIONS ---
# Connect the 'pressed()' signal from each TextureButton to these functions:

func _on_orange_select_pressed():
	select_and_spawn("orange")

func _on_black_select_pressed():
	CAT_SCENE = preload("res://BlackCat.tscn")
	select_and_spawn("black")

func _on_white_select_pressed():
	CAT_SCENE = preload("res://WhiteCat.tscn")	
	select_and_spawn("white")

# --- CORE LOGIC ---

func select_and_spawn(color_string):
	# print(color_string)
	var cat_scene_root = CAT_SCENE.instantiate()
	var cat_body = cat_scene_root.get_node("CharacterBody2D")
	
	# 1. SET THE COLOR FIRST
	cat_body.cat_type = color_string
	
	# 2. THEN ADD TO THE WORLD
	get_tree().current_scene.add_child(cat_scene_root)
	
	cat_scene_root.global_position = spawn_point.global_position
	self.hide()
