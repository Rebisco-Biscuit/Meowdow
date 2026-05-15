extends Sprite2D
class_name Crop

@export var data: CropData

var stage := 1
var timer := 0.0
var shadow: Sprite2D

func _ready():
	# --- SHADOW SETUP ---
	shadow = Sprite2D.new()
	shadow.region_enabled = true
	shadow.centered = false
	shadow.modulate = Color(0, 0, 0, 0.4)
	shadow.z_index = -1
	add_child(shadow)

	region_enabled = true
	texture = data.spritesheet
	_update_sprite()

func _process(delta):
	if stage < data.stage_rects.size():
		timer += delta
		if timer >= data.stage_duration:
			timer = 0.0
			stage += 1
			_update_sprite()

func _update_sprite():
	region_rect = data.stage_rects[stage - 1]
	offset = Vector2(0, -region_rect.size.y / 2.0)

	shadow.texture = data.spritesheet
	shadow.region_rect = data.stage_rects[stage - 1]
	shadow.offset = Vector2(-6, -region_rect.size.y / 1.0)

func harvest():
	var amount = randi_range(1, 5)

	# --- Spawn collectables ---
	for i in range(amount):
		var item = data.harvestable_scene.instantiate()
		item.global_position = global_position + Vector2(
			randf_range(-8, 8),
			randf_range(-8, 8)
		)
		get_parent().add_child(item)

	# --- Count how many actually went into inventory ---
	# We read the inventory AFTER spawning so collectables
	# that get auto-collected register correctly.
	# Use amount as the count since each collectable = 1 insert.
	GlobalData.on_crop_harvested(data.crop_name, amount)

	queue_free()
