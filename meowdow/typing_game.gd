extends Control

# --- CONSTANTS ---
const GAME_DURATION = 60.0
const MAX_SEEDS = 15
const MIN_SEEDS = 10

# --- WPM config (set by dev NPC before adding to tree) ---
var dev_wpm: int = 60  # overridden from GlobalData in _ready()

# --- WORD LIST ---
const WORDS = [
	"cat", "paw", "seed", "grow", "farm", "soil", "rain", "sun", "leaf", "root",
	"crop", "corn", "dirt", "barn", "pond", "frog", "dew", "mist", "bud", "stem",
	"meow", "purr", "nap", "yarn", "mouse", "grass", "stone", "path", "gate", "hay",
	"flower", "garden", "harvest", "sprout", "carrot", "tomato", "basket", "shovel",
	"watering", "morning", "evening", "whisker", "kitten", "catnip", "burrow", "meadow",
	"hollow", "sunrise", "foggy", "pebble", "acorn", "bramble", "thicket", "lantern"
]

# --- SEED SCENES ---
var seed_scenes = [
	preload("res://inventory/collectables/carrot_seed.tscn"),
	preload("res://inventory/collectables/corn_seed.tscn"),
	preload("res://inventory/collectables/beetroot_seed.tscn"),
	preload("res://inventory/collectables/berries_seed.tscn"),
	preload("res://inventory/collectables/tomato_seed.tscn"),
	preload("res://inventory/collectables/strawberry_seed.tscn"),
]

# --- STATE ---
var time_left: float = GAME_DURATION

# Player
var snake_length: int = 0
var current_word: String = ""

# Dev AI
var dev_score := 0
var dev_current_word: String = ""

# Typing animation
var dev_typing_text := ""
var dev_typing_index := 0
var dev_typing_timer := 0.0
var dev_typing_speed := 0.03  # overridden in start_game() based on dev_wpm

# AI timing
var ai_timer := 0.0
var ai_target_time := 0.0
var ai_interval_min := 0.7   # overridden in start_game() based on dev_wpm
var ai_interval_max := 1.3   # overridden in start_game() based on dev_wpm

var game_active: bool = false
var return_scene: String = ""

# --- NODES ---
@onready var word_label: Label = $VBoxContainer/WordLabel
@onready var input_field: LineEdit = $PlayerSide/NinePatchRect/MarginContainer/InputField

@onready var timer_label: Label = $VBoxContainer/TimerLabel
@onready var score_label: Label = $VBoxContainer2/VBoxContainer/ScoreLabel

@onready var start_button: Button = $VBoxContainer2/VBoxContainer/StartButton

@onready var result_panel: Panel = $ResultPanel
@onready var result_label: Label = $ResultPanel/VBoxContainer/ResultLabel
@onready var reward_label: Label = $ResultPanel/VBoxContainer/RewardLabel
@onready var difficulty_label: Label = $DevSide/NinePatchRect/MarginContainer/Difficulty

@onready var play_again_button: Button = $ResultPanel/VBoxContainer/PlayAgainButton
@onready var quit_button: Button = $ResultPanel/VBoxContainer/QuitButton
@onready var back_button: Button = $VBoxContainer2/VBoxContainer/BackButton

@onready var snake_bar: ProgressBar = $VBoxContainer2/VBoxContainer/SnakeBar

@onready var player_word_count = $PlayerSide/Label/WordCount
@onready var dev_word_count = $DevSide/Label2/WordCount

@onready var dev_input_field = $DevSide/NinePatchRect/MarginContainer/DevInputField
@onready var dev_sprite = $DevSide/AnimatedSprite2D
@onready var dev_name = $DevSide/Label2/PlayerLabel

func _ready():
	return_scene = GlobalData.last_map
	dev_wpm = GlobalData.dev_wpm
	if GlobalData.dev_sprite_frames:
		dev_sprite.sprite_frames = GlobalData.dev_sprite_frames
		dev_sprite.play("default")

	result_panel.visible = false
	input_field.editable = false
	dev_input_field.editable = false
	dev_input_field.focus_mode = Control.FOCUS_NONE
	dev_input_field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dev_name.text = GlobalData.dev_name

	word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	word_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	word_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	word_label.add_theme_font_size_override("font_size", 32)
	word_label.text = "Press Start to play!"

	score_label.text = "Length: 0"
	timer_label.text = "60s"

	player_word_count.text = "Words: 0"
	dev_word_count.text = "Words: 0"

	difficulty_label.text = "%s" % GlobalData.dev_wpm + " WPM"

	snake_bar.max_value = 30
	snake_bar.value = 0

	input_field.text_changed.connect(_on_text_changed)
	start_button.pressed.connect(_on_start_pressed)
	play_again_button.pressed.connect(_on_play_again_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	back_button.pressed.connect(_on_quit_pressed)


func _process(delta):
	if not game_active:
		return

	time_left -= delta
	timer_label.text = str(int(ceil(time_left))) + "s"

	# --- DEV TYPING ANIMATION ---
	if dev_typing_index < dev_typing_text.length():
		dev_typing_timer += delta

		if dev_typing_timer >= dev_typing_speed:
			dev_typing_timer = 0.0
			dev_typing_index += 1
			dev_input_field.text = dev_typing_text.substr(0, dev_typing_index)

	# --- AI LOGIC ---
	ai_timer += delta

	if ai_timer >= ai_target_time:

		# start typing animation
		dev_typing_text = dev_current_word
		dev_typing_index = 0
		dev_typing_timer = 0.0

		# success chance (kept simple)
		if randf() <= 0.72:
			dev_score += 1
			dev_word_count.text = "Words: " + str(dev_score)

		# next word
		next_dev_word()
		set_next_ai_time()

	# --- COMEBACK BALANCE ---
	if dev_score - snake_length >= 5:
		ai_target_time += 0.3

	if time_left <= 0:
		end_game()


func _on_start_pressed():
	start_game()


func start_game():
	time_left = GAME_DURATION

	snake_length = 0
	dev_score = 0

	game_active = true
	input_field.editable = true

	start_button.visible = false
	result_panel.visible = false

	score_label.text = "Length: 0"

	player_word_count.text = "Words: 0"
	dev_word_count.text = "Words: 0"

	snake_bar.value = 0

	word_label.add_theme_font_size_override("font_size", 75)

	# --- Apply WPM to AI speed ---
	# Seconds per word = 60 / wpm
	# Typing speed per char = seconds_per_word / avg_word_length (5)
	var seconds_per_word = 60.0 / float(dev_wpm)
	dev_typing_speed = seconds_per_word / 5.0
	ai_interval_min  = seconds_per_word * 0.85
	ai_interval_max  = seconds_per_word * 1.2

	next_player_word()
	next_dev_word()

	input_field.grab_focus()

	set_next_ai_time()


func set_next_ai_time():
	ai_target_time = randf_range(ai_interval_min, ai_interval_max) + (dev_current_word.length() * 0.01)
	ai_timer = 0.0


# --- PLAYER WORDS ---
func next_player_word():
	current_word = WORDS[randi() % WORDS.size()]
	word_label.text = current_word
	input_field.text = ""


# --- DEV WORDS ---
func next_dev_word():
	dev_current_word = WORDS[randi() % WORDS.size()]

	# reset typing visuals
	dev_typing_text = ""
	dev_typing_index = 0
	dev_typing_timer = 0.0
	dev_input_field.text = ""


func _on_text_changed(new_text: String):
	if not game_active:
		return

	if new_text.strip_edges().to_lower() == current_word:
		snake_length += 1
		player_word_count.text = "Words: " + str(snake_length)
		snake_bar.value = snake_length
		next_player_word()


func end_game():
	game_active = false
	input_field.editable = false

	word_label.add_theme_font_size_override("font_size", 32)
	word_label.text = "Time's up!"

	# reward scaling
	var ratio = clamp(float(snake_length) / 30.0, 0.0, 1.0)
	var seed_count = int(lerp(float(MIN_SEEDS) * 0.3, float(MAX_SEEDS), ratio))
	seed_count = max(1, seed_count)

	# give rewards
	var inventory = GlobalData.get_player_inventory()
	if inventory:
		for i in range(seed_count):
			var seed_scene = seed_scenes[randi() % seed_scenes.size()]
			var seed_item = seed_scene.instantiate()
			if seed_item.get("item") != null:
				inventory.insert(seed_item.item)
			seed_item.queue_free()

	# results
	result_panel.visible = true

	if snake_length > dev_score:
		result_label.text = "You beat the Dev!"
		reward_label.text = "You earned $35!"
		GlobalData.catnips += 35
		GlobalData.create_save()
	else:
		result_label.text = "The Dev defeated you!"
		if GlobalData.catnips > 50:
			reward_label.text = "You lost $20! Better luck next time!"			
			GlobalData.catnips -= 20
			GlobalData.create_save()
		else:
			reward_label.text = "Better luck next time!"

	start_button.visible = false


func _on_play_again_pressed():
	start_game()


func _on_quit_pressed():
	get_tree().change_scene_to_file(return_scene)
