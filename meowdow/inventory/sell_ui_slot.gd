extends Button

@onready var container: CenterContainer = $CenterContainer

var itemStackGui: ItemStackGui
var inventorySlot
var index := 0

func insert(isg: ItemStackGui):

	itemStackGui = isg
	inventorySlot = isg.inventorySlot

	container.add_child(isg)

func clear():

	if itemStackGui:
		container.remove_child(itemStackGui)
		itemStackGui = null
		inventorySlot = null

func is_empty():
	return itemStackGui == null
