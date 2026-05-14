extends Control

@onready var character_selection_box = $VBoxContainer/Panel/HBoxContainer
@onready var indicator = $VBoxContainer/Panel/Indicator

var bg_scene = preload("res://startdialogue.tscn")

func _ready():
	indicator.visible = false

func _input(event):
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		var charNode = _get_char_node()
		if charNode:
			_set_char_selected(charNode)

func _get_char_node():
	var mousePos = get_viewport().get_mouse_position()
	for node in character_selection_box.get_children():
		if node.get_global_rect().has_point(mousePos):
			return node

func _set_char_selected(charNode):
	GlobalData.playerCharPath = charNode.characterPath
	GlobalData.selectedCatType = charNode.catType
	print("Selected cat type: ", GlobalData.selectedCatType)

	indicator.visible = true
	indicator.position = charNode.position

	for node in character_selection_box.get_children():
		var isSelected = charNode == node
		node.set_selected(isSelected)

func _on_button_pressed() -> void:
	if not GlobalData.playerCharPath:
		return

	var bg = bg_scene.instantiate()
	get_tree().root.add_child(bg)

	var skip_btn = preload("res://skip_button.tscn").instantiate()
	get_tree().root.add_child(skip_btn)

	GlobalData.sync_to_dialogic()
	var dialog = Dialogic.start("res://Timelines/towns/Town1_Start.dtl")
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in dialog.get_children():
		child.process_mode = Node.PROCESS_MODE_ALWAYS

	if not GlobalData.has_received_starter_catnips:
		GlobalData.catnips += 200
		GlobalData.has_received_starter_catnips = true
		print("Guide gave 200 catnips!")

	Dialogic.timeline_ended.connect(func():
		if skip_btn and is_instance_valid(skip_btn):
			skip_btn.queue_free()		
		bg.queue_free()
		GlobalData.last_map = "res://Vinalore.tscn"
		GlobalData.create_save()  # ← save HERE after everything is set
		get_tree().change_scene_to_file("res://Vinalore.tscn")
	, CONNECT_ONE_SHOT)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
