extends Resource
class_name ShopItem

@export var item_scene: PackedScene
@export var icon: Texture2D
@export var item_name: String = ""
@export var price: int = 5
@export var locked: bool = false
@export var unlock_map: String = ""  # e.g. "aubrialis" or "rhollow"
