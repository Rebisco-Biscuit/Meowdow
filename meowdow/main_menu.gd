extends CanvasLayer

func _ready():
	var blur_material = ShaderMaterial.new()
	blur_material.shader = load("res://shaders/blur.gdshader")
	blur_material.set_shader_parameter("blur_amount", 2)
	
	var blur_cat = ShaderMaterial.new()
	blur_cat.shader = load("res://shaders/blur.gdshader")
	blur_cat.set_shader_parameter("blur_amount", 0.5)
	
	$TextureRect.material = blur_material
	$Node2D/AnimatedSprite2D.material = blur_cat
	$Node2D/Sprite2D2.material = blur_cat
	
	GlobalData.check_save()
	$VBoxContainer/Continue.visible = GlobalData.has_save

func _on_continue_pressed():
	GlobalData.load_save()	
	get_tree().change_scene_to_file(GlobalData.last_map)

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://selection_screen.tscn")

func _on_settings_pressed():
	pass  # hook up later

func _on_quit_pressed():
	get_tree().quit()
