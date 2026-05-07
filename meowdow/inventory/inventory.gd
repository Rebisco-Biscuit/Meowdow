extends Resource

class_name Inv

signal updated

@export var slots: Array[InventorySlot]

func insert(item: InvItem):
	var itemSlots = slots.filter(func(slot): return slot.item == item and slot.amount < item.maxAmountPerStack)
	if !itemSlots.is_empty():
		itemSlots[0].amount += 1
	else:
		var emptySlots = slots.filter(func(slot): return slot.item == null)
		if !emptySlots.is_empty():
			emptySlots[0].item = item
			emptySlots[0].amount = 1
	
	updated.emit()

func remove(item: InvItem):
	for slot in slots:
		if slot.item == item:
			slot.amount -= 1
			if slot.amount <= 0:
				slot.item = null
				slot.amount = 0
			updated.emit()
			return
			

func removeSlot(inventorySlot: InventorySlot):
	var index = slots.find(inventorySlot)
	if index < 0: return
	
	slots[index] = InventorySlot.new()

func insertSlot(index: int, inventorySlot: InventorySlot):
	slots[index] = inventorySlot
