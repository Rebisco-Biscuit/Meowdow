extends Node2D

var settings_instance = null

func _ready():
	visible = false

func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("menu"):
			toggle()

func toggle():
	visible = !visible
	get_tree().paused = visible

func _on_resume_pressed():
	toggle()

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

func _on_save_pressed():
	GlobalData.create_save()
	print("Game saved!")

func _on_save_and_quit_pressed():
	GlobalData.create_save()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")
