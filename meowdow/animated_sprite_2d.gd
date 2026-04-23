extends AnimatedSprite2D

var last_dir = "s" 
var is_farming = false
var is_afk = false # New lock for AFK
var idle_timer = 0.0
var afk_threshold = 10.0 

func _process(delta):
	# 1. LOCKS: If doing a special action, stop movement logic
	if is_farming or is_afk:
		return

	# 2. FARMING INPUT
	if Input.is_action_just_pressed("farm"):
		start_farming()
		return

	# 3. MOVEMENT & AFK TIMER
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")

	if direction != Vector2.ZERO:
		idle_timer = 0.0
		update_direction_string(direction)
		play_safe("orange_cat_walk_" + last_dir)
	else:
		idle_timer += delta
		if idle_timer >= afk_threshold:
			start_afk() # Trigger the special idle
		else:
			play_safe("orange_cat_idle_" + last_dir)

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
	play_safe("orange_cat_farm_" + farm_dir)

func start_afk():
	is_afk = true
	# This coin flip now only happens ONCE when the timer hits 60s
	var anim_to_play = "orange_cat_afk"
	if randf() > 0.5:
		anim_to_play = "orange_cat_afk2"
	
	play_safe(anim_to_play)

func play_safe(anim_name):
	if sprite_frames.has_animation(anim_name):
		if animation != anim_name:
			play(anim_name)

func _on_animation_finished():
	# Unlock the cat regardless of which special animation finished
	is_farming = false
	is_afk = false
	idle_timer = 0.0 # Reset the clock to wait another minute
	play_safe("orange_cat_idle_" + last_dir)


func _on_animated_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.
