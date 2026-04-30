extends AnimatedSprite2D

@export_enum("orange", "black", "white") var cat_type: String = "orange"

var last_dir = "s" 
var is_farming = false
var is_afk = false
var idle_timer = 0.0
var afk_threshold = 10.0 



func _process(delta):
	# 1. THE HARD LOCK: Farming cannot be interrupted
	if is_farming:
		return

	# 2. MOVEMENT CHECK: This can interrupt AFK
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")

	if direction != Vector2.ZERO:
		# If we move, we are no longer AFK
		if is_afk:
			is_afk = false
		
		idle_timer = 0.0
		update_direction_string(direction)
		play_safe(cat_type + "_cat_walk_" + last_dir)
		return # Exit so we don't hit the AFK logic below

	# 3. THE SOFT LOCK: If we are AFK and NOT moving, stay locked
	if is_afk:
		return

	# 4. FARMING INPUT
	if Input.is_action_just_pressed("farm"):
		start_farming()
		return

	# 5. IDLE & AFK TIMER
	idle_timer += delta
	if idle_timer >= afk_threshold:
		start_afk()
	else:
		play_safe(cat_type + "_cat_idle_" + last_dir)

func update_direction_string(dir):
	var horizontal = ""
	var vertical = ""
	if sign(dir.x) == -1: horizontal = "a"
	elif sign(dir.x) == 1: horizontal = "d"
	if sign(dir.y) == -1: vertical = "w"
	elif sign(dir.y) == 1: vertical = "s"
	last_dir = horizontal + vertical

func start_farming():
	is_farming = true
	idle_timer = 0.0
	var farm_dir = last_dir.left(1)
	play_safe(cat_type + "_cat_farm_" + farm_dir)

func start_afk():
	is_afk = true
	var anim_to_play = cat_type + "_cat_afk"
	if randf() > 0.5:
		anim_to_play = cat_type + "_cat_afk2"
	play_safe(anim_to_play)

func play_safe(anim_name):
	if sprite_frames.has_animation(anim_name):
		if animation != anim_name:
			play(anim_name)

func _on_animation_finished():
	# Farming only unlocks when the animation actually ends
	if is_farming:
		is_farming = false
	
	# AFK naturally finishes if not interrupted
	is_afk = false
	idle_timer = 0.0
	play_safe(cat_type + "_cat_idle_" + last_dir)
