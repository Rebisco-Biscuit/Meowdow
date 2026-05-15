extends Control

@onready var audio      = $AudioStreamPlayer2D
@onready var container  = $TargetContainer
@onready var progress   = $ProgressBar
@onready var end_label  = $EndLabel

var font = preload("res://assets/Minecraft.ttf")
var beats = []
var index = 0
var song_time = 0.0

# --- Boss HP ---
const BOSS_MAX_HP    := 100.0
const PERFECT_DAMAGE := 4.0
const GOOD_DAMAGE    := 2.0
const MAX_MISTAKES   := 5

var boss_hp   := BOSS_MAX_HP
var mistakes  := 0
var game_over := false

var target_scene = preload("res://boss_button-test.tscn")

func _ready():
	progress.min_value = 0
	progress.max_value = BOSS_MAX_HP
	end_label.visible = false
	_update_hud()
	if load_beats():
		audio.play()
	else:
		end_label.visible = true
		end_label.text = "ERROR: beats.json not found"


# ---------- HUD ----------
func _update_hud():
	progress.value = boss_hp


# ---------- Beat loading ----------
func load_beats() -> bool:
	if not FileAccess.file_exists("res://meow-sic/beats.json"):
		push_error("beats.json not found at res://meow-sic/beats.json")
		return false

	var file = FileAccess.open("res://meow-sic/beats.json", FileAccess.READ)
	if file == null:
		push_error("Failed to open beats.json: " + str(FileAccess.get_open_error()))
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	if parsed == null or not parsed is Array:
		push_error("beats.json is invalid or not a JSON array")
		return false

	beats = parsed
	return true


# ---------- Main loop ----------
func _process(delta):
	if game_over:
		return
	song_time += delta
	if index < beats.size() and song_time >= beats[index]:
		spawn_target(beats[index])
		index += 1


# ---------- Spawning ----------
func spawn_target(hit_time):
	var t = target_scene.instantiate()
	t.hit_time = hit_time
	t.manager  = self
	container.add_child(t)

	var pos = Vector2(randf_range(100, 802), randf_range(200, 462))
	t.position = pos

	get_tree().create_timer(2.1).timeout.connect(func():
		if is_instance_valid(t):
			t.queue_free()
			_on_mistake(pos, "MISS")
	)


# ---------- Hit registration ----------
func register_hit(target):
	if game_over:
		target.queue_free()
		return

	var diff    = abs(song_time - target.hit_time)
	var hit_pos = target.position
	target.queue_free()

	if diff < 1.0:
		_show_floating_label(hit_pos, "CRIT")
		_deal_damage(PERFECT_DAMAGE)
	elif diff < 2.0:
		_show_floating_label(hit_pos, "HIT")
		_deal_damage(GOOD_DAMAGE)
	else:
		_on_mistake(hit_pos, "BAD")


func _deal_damage(amount: float):
	boss_hp = max(0.0, boss_hp - amount)
	_update_hud()
	if boss_hp <= 0.0:
		_end_game(true)

func _on_mistake(pos: Vector2, text: String):
	mistakes += 1
	_show_floating_label(pos, text)
	_update_hud()
	if mistakes >= MAX_MISTAKES:
		_end_game(false)


# ---------- Floating label just above the button ----------
func _show_floating_label(pos: Vector2, text: String):
	var fl = Label.new()
	fl.text = text
	fl.add_theme_font_size_override("font_size", 20)

	match text:
		"CRIT": fl.modulate = Color(1.0, 0.9, 0.2)  # gold
		"HIT":  fl.modulate = Color(0.4, 1.0, 0.4)  # green
		"BAD":  fl.modulate = Color(1.0, 0.4, 0.4)  # red
		"MISS": fl.modulate = Color(0.6, 0.6, 0.6)  # grey

	fl.position = pos + Vector2(0, -8)
	add_child(fl)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(fl, "position", fl.position + Vector2(0, -20), 0.8)
	tween.tween_property(fl, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(fl.queue_free)


# ---------- End game ----------
func _end_game(won: bool):
	game_over = true
	audio.stop()
	for child in container.get_children():
		child.queue_free()

	end_label.visible = true
	end_label.add_theme_font_size_override("font_size", 48)

	if won:
		end_label.text     = "ECHOFALL DEFEATED!"
		end_label.modulate = Color(1.0, 0.9, 0.2)
		GlobalData.echofall_defeated = true
		print(GlobalData.echofall_defeated)
		GlobalData.quest_step = 21
		GlobalData.create_save()
	else:
		end_label.text     = "GAME OVER"
		end_label.modulate = Color(1.0, 0.3, 0.3)
		GlobalData.echofall_defeated = false
		GlobalData.create_save()

	# Return to map after 2 seconds
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file(GlobalData.last_map)
