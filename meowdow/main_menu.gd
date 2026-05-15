extends CanvasLayer

var settings_instance = null


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
	if FileAccess.file_exists(GlobalData.SAVE_PATH):
		DirAccess.remove_absolute(GlobalData.SAVE_PATH)

	GlobalData.reset()
	get_tree().change_scene_to_file("res://selection_screen.tscn")

func _on_settings_pressed():
	if settings_instance == null:
		settings_instance = preload("res://settings_menu.tscn").instantiate()
		add_child(settings_instance)
		# Connect the close signal from settings back to here
		settings_instance.closed.connect(_on_settings_closed)

func _on_settings_closed():
	if settings_instance:
		settings_instance.queue_free()
		settings_instance = null

func _on_quit_pressed():
	get_tree().quit()
