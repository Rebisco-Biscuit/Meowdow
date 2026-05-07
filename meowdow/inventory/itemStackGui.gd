extends Panel

class_name ItemStackGui

@onready var item_visual: Sprite2D = $item_display
@onready var amountLabel: Label = $Label 

var inventorySlot: InventorySlot

func update():
	if !inventorySlot || !inventorySlot.item: return
	
	item_visual.visible = true
	item_visual.texture = inventorySlot.item.texture
	
	if inventorySlot.amount > 1:
		amountLabel.visible = true
		amountLabel.text = str(inventorySlot.amount)
	else:
			amountLabel.visible = false
