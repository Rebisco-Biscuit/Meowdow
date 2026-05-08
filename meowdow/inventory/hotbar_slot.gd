extends Button

@onready var item_stack_gui: ItemStackGui = $CenterContainer/Panel

func update_to_slot(slot: InventorySlot) -> void:
	if !slot.item:
		item_stack_gui.visible = false
		return
	
	item_stack_gui.inventorySlot = slot
	item_stack_gui.update()
	item_stack_gui.visible = true
