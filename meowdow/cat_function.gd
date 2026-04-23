extends CharacterBody2D

@export var speed = 200.0
@onready var sprite = $AnimatedSprite2D
@export_enum("orange", "black", "white") var cat_type: String = "orange"

var last_dir = "s" 
var is_farming = false
var is_afk = false
var idle_timer = 0.0
var afk_threshold = 10.0 

func _physics_process(delta):
	# 1. THE HARD LOCK: Farming kills all movement
	if is_farming:
		velocity = Vector2.ZERO
		move_and_slide() # Keeps physics updated but with zero speed
		return

	# 2. MOVEMENT INPUT
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		# Movement interrupts AFK
		is_afk = false
		idle_timer = 0.0
		
		update_direction_string(direction)
		velocity = direction * speed
		sprite.play_safe(cat_type + "_cat_walk_" + last_dir)
	else:
		# Apply friction/stop
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		
		# 3. SOFT LOCK: Only process AFK if we aren't moving
		if is_afk:
			move_and_slide()
			return

		# 4. AFK TIMER
		idle_timer += delta
		if idle_timer >= afk_threshold:
			start_afk()
		else:
			sprite.play_safe(cat_type + "_cat_idle_" + last_dir)

	# 5. FARMING INPUT (Only if standing still)
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
	velocity = Vector2.ZERO # Stop momentum immediately
	idle_timer = 0.0
	var farm_dir = last_dir.left(1)
	sprite.play_safe(cat_type + "_cat_farm_" + farm_dir)

func start_afk():
	is_afk = true
	var anim = cat_type + "_cat_afk" if randf() > 0.5 else cat_type + "_cat_afk2"
	sprite.play_safe(anim)

# Make sure this is connected to the AnimatedSprite2D's animation_finished signal!
func _on_animation_finished():
	is_farming = false
	is_afk = false
	idle_timer = 0.0
	sprite.play_safe(cat_type + "_cat_idle_" + last_dir)
	
# Add this to the very bottom of orange_cat.gd
func play_safe(anim_name: String):
	# We check 'sprite.sprite_frames' because 'sprite' is our AnimatedSprite2D child
	if sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:
			sprite.play(anim_name)
	else:
		print("Warning: Animation not found: ", anim_name)


func _on_animated_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.
