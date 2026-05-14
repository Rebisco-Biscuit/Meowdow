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
	shadow.modulate = Color(0, 0, 0, 0.4)  # black, semi-transparent
	shadow.z_index = -1  # always behind crop
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
	shadow.offset = Vector2(-6, -region_rect.size.y / 1.0)  # tweak this for shadow position
	
func harvest():
	if data.crop_name == "carrot":
		GlobalData.gigglerain_count += 1
		if GlobalData.gigglerain_count >= 100 and GlobalData.quest_step == 3:
			GlobalData.quest_step = 4
	if data.crop_name == "corn" and GlobalData.quest_step == 6:
		GlobalData.wheepingwheat_count += 1
		GlobalData.quest_step = 7				
	var item = data.harvestable_scene.instantiate()
	item.global_position = global_position
	get_parent().add_child(item)
	queue_free()
