extends Node2D

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
	pass  # hook up later

func _on_save_pressed():
	GlobalData.create_save()
	print("Game saved!")

func _on_save_and_quit_pressed():
	GlobalData.create_save()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")
