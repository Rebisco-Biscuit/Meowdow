extends Panel

@onready var inventory: Inv = preload("res://inventory/playerinv.tres")
@onready var slots: Array = $Container.get_children()
@onready var selector: Sprite2D = $Selector

var currently_selected: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()
	inventory.updated.connect(update)

func update() -> void:
	for i in range(slots.size()):
		var inventory_slot: InventorySlot = inventory.slots[i]
		slots[i].update_to_slot(inventory_slot)

func move_selector(direction: int) -> void:
	currently_selected = (currently_selected + direction) % slots.size()
	if currently_selected < 0:
		currently_selected = slots.size() - 1
		
	selector.global_position = slots[currently_selected].global_position

func _unhandled_input(event) -> void:
	if event.is_action_pressed("hotbar_right"):
		move_selector(1)
		
	if event.is_action_pressed("hotbar_left"):
		move_selector(-1)
		
func get_selected_item() -> InvItem:
	var slot: InventorySlot = inventory.slots[currently_selected]
	return slot.item  # adjust if your InventorySlot uses a different field name		
