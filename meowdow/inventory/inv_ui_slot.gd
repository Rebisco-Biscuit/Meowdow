extends Button

@onready var container:CenterContainer = $CenterContainer

@onready var inventory = preload("res://inventory/playerinv.tres")

var itemStackGui: ItemStackGui
var index: int

func insert(isg: ItemStackGui):
	itemStackGui = isg
	container.add_child(itemStackGui)
	
	if !itemStackGui.inventorySlot || inventory.slots[index] == itemStackGui.inventorySlot:
		return
	
	inventory.insertSlot(index, itemStackGui.inventorySlot)

func takeItem():
	var item = itemStackGui
	
	inventory.removeSlot(itemStackGui.inventorySlot)
	
	return item

func isEmpty():
	return !itemStackGui
	

func clear() -> void:
	if itemStackGui:
		container.remove_child(itemStackGui)
		itemStackGui = null
