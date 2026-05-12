extends Control

@onready var master_slider = $VBoxContainer/baseSettingsBox/VBoxContainer/Master/HBoxContainer/MasterScrollBar
@onready var music_slider = $VBoxContainer/baseSettingsBox/VBoxContainer/Music/HBoxContainer/MusicScrollBar
@onready var sfx_slider = $VBoxContainer/baseSettingsBox/VBoxContainer/SFX/HBoxContainer/SFXScrollBar
@onready var meow_slider = $VBoxContainer/baseSettingsBox/VBoxContainer/Meow/HBoxContainer/MeowScrollBar

var is_open = false

func _ready():

	master_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	)

	music_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	)

	sfx_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	)

	meow_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Meow"))
	)

func _on_master_scroll_bar_value_changed(value: float):
	set_bus_volume("Master", value)

func _on_meow_scroll_bar_value_changed(value: float):
	set_bus_volume("Music", value)

func _on_music_scroll_bar_value_changed(value: float):
	set_bus_volume("SFX", value)


func _on_sfx_scroll_bar_value_changed(value: float):
	set_bus_volume("Meow", value)

func set_bus_volume(bus_name: String, value: float):

	var bus_index = AudioServer.get_bus_index(bus_name)

	if value <= 0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(
			bus_index,
			linear_to_db(value)
		)

func _on_master_minus_button_pressed() -> void:
	master_slider.value = clamp(master_slider.value - 0.1, 0, 1)

func _on_master_plus_button_pressed() -> void:
	master_slider.value = clamp(master_slider.value + 0.1, 0, 1)


func _on_meow_minus_button_pressed() -> void:
	meow_slider.value = clamp(meow_slider.value - 0.1, 0, 1)

func _on_meow_plus_button_pressed() -> void:
	meow_slider.value = clamp(meow_slider.value + 0.1, 0, 1)

func _on_music_minus_button_pressed() -> void:
	music_slider.value = clamp(music_slider.value - 0.1, 0, 1)

func _on_music_plus_button_pressed() -> void:
	music_slider.value = clamp(music_slider.value + 0.1, 0, 1)

func _on_sfx_minus_button_pressed() -> void:
	sfx_slider.value = clamp(sfx_slider.value - 0.1, 0, 1)

func _on_sfx_plus_button_pressed() -> void:
	sfx_slider.value = clamp(sfx_slider.value + 0.1, 0, 1)

func _on_exit_button_pressed() -> void:
	if is_open:
		close()
	else:
		open()

func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false
