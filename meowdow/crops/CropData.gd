extends Resource
class_name CropData

@export var crop_name: String = "unknown"
@export var spritesheet: Texture2D
@export var stage_rects: Array[Rect2] = []
@export var harvestable_scene: PackedScene
@export var stage_duration: float = 60.0
