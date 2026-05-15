extends Resource

class_name Inv

signal updated

@export var slots: Array[InventorySlot] = []

func _init():
	if slots == null:
		slots = []

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
	
	remove_at_index(index)
	

func remove_at_index(index: int) -> void:
	slots[index] = InventorySlot.new()
	updated.emit()

func insertSlot(index: int, inventorySlot: InventorySlot):
	slots[index] = inventorySlot
	updated.emit()

func use_item_at_index(index: int) -> void:
	if index < 0 || index >= slots.size() || !slots[index].item: return
	
	var slot = slots[index]
	
	if slot.amount > 1:
		slot.amount -= 1
		updated.emit()
		return
		
	remove_at_index(index)

func get_item_count(item: InvItem) -> int:
	var total := 0
	
	for slot in slots:
		if slot.item == item:
			total += slot.amount
			
	return total
