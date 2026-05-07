extends Sprite2D

var stage := 1
var timer := 0.0
const STAGE_DURATION := 4.5

var carrot_scene = preload("res://inventory/collectables/carrot.tscn")

const STAGE_RECTS = [
	Rect2(32, 16, 16, 16),  # stage 1
	Rect2(64, 16, 16, 16),  # stage 2
	Rect2(96, 16, 16, 16),  # stage 3
]

func _ready():
	region_enabled = true
	_update_sprite()

func _process(delta):
	if stage < 3:
		timer += delta
		if timer >= STAGE_DURATION:
			timer = 0.0
			stage += 1
			_update_sprite()

func _update_sprite():
	region_rect = STAGE_RECTS[stage - 1]

func harvest():
	var carrot = carrot_scene.instantiate()
	carrot.global_position = global_position
	get_parent().add_child(carrot)
	queue_free()
