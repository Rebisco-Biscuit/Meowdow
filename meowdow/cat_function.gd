extends CharacterBody2D

@export var speed = 100.0
@onready var sprite = $AnimatedSprite2D
@onready var shadow = $Sprite2D
@onready var meow_player = $MeowPlayer

@export_enum("orange", "black", "white") var cat_type: String = "orange"

var last_dir = "s" 
var is_farming = false
var is_afk = false
var idle_timer = 0.0
var afk_threshold = 10.0 

# --- MEOW SYSTEM ---
var meows = [
	preload("res://meow-sic/meow1.mp3"),
	preload("res://meow-sic/meow2.mp3"),
	preload("res://meow-sic/meow3.mp3"),
	preload("res://meow-sic/meow4.mp3")
]

var meow_timer := 0.0
var next_meow_time := 0.0
# -------------------

func _ready():
	randomize()
	set_next_meow_time()

func _physics_process(delta):
	shadow.global_position = global_position + Vector2(0, 6)

	# --- MEOW TIMER ---
	meow_timer += delta
	if meow_timer >= next_meow_time:
		play_meow()
		meow_timer = 0.0
		set_next_meow_time()
	# ------------------

	# 1. THE HARD LOCK: Farming kills all movement
	if is_farming:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# 2. MOVEMENT INPUT
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		is_afk = false
		idle_timer = 0.0
		
		update_direction_string(direction)
		velocity = direction * speed
		sprite.play_safe(cat_type + "_cat_walk_" + last_dir)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		
		if is_afk:
			move_and_slide()
			return

		idle_timer += delta
		if idle_timer >= afk_threshold:
			start_afk()
		else:
			sprite.play_safe(cat_type + "_cat_idle_" + last_dir)

	# 5. FARMING INPUT
	if Input.is_action_just_pressed("farm"):
		start_farming()

	move_and_slide()


func update_direction_string(dir):
	var horizontal = ""
	var vertical = ""
	if dir.x < 0: horizontal = "a"
	elif dir.x > 0: horizontal = "d"
	if dir.y < 0: vertical = "w"
	elif dir.y > 0: vertical = "s"
	last_dir = horizontal + vertical


func start_farming():
	is_farming = true
	velocity = Vector2.ZERO
	idle_timer = 0.0
	var farm_dir = last_dir.left(1)
	sprite.play_safe(cat_type + "_cat_farm_" + farm_dir)


func start_afk():
	is_afk = true
	var anim = cat_type + "_cat_afk" if randf() > 0.5 else cat_type + "_cat_afk2"
	sprite.play_safe(anim)


func _on_animation_finished():
	is_farming = false
	is_afk = false
	idle_timer = 0.0
	sprite.play_safe(cat_type + "_cat_idle_" + last_dir)


func play_safe(anim_name: String):
	if sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:
			sprite.play(anim_name)
	else:
		print("Warning: Animation not found: ", anim_name)


# --- MEOW HELPERS ---
func set_next_meow_time():
	next_meow_time = randf_range(4.5, 10.0) # tweak if your cat gets annoying


func play_meow():
	if meow_player == null:
		print("MeowPlayer missing. Incredible.")
		return

	if meow_player.playing:
		return # don't overlap like a broken speaker

	meow_player.stream = meows.pick_random()
	meow_player.pitch_scale = randf_range(0.9, 1.1)
	meow_player.play()
# --------------------
