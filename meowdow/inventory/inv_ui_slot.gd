extends Panel

@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display
@onready var amountLabel: Label = $CenterContainer/Panel/Label 

func update(slot: InventorySlot):
	if !slot.item:
		item_visual.visible = false
		amountLabel.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = slot.item.texture
		
		if slot.amount > 1:
			amountLabel.visible = true
			amountLabel.text = str(slot.amount)
		else:
			amountLabel.visible = false
