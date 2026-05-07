extends Control

@onready var inv: Inv = preload("res://inventory/playerinv.tres")
@onready var ItemStackGuiClass = preload("res://inventory/itemStackGui.tscn")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open = false
var itemInHand = null

func _ready():
	connectSlots()
	inv.updated.connect(update_slots)
	update_slots()
	close()

func connectSlots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		
		var callable = Callable(onSlotClicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func refresh():
	update_slots()

func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
			var inventorySlot: InventorySlot = inv.slots[i]
			
			if !inventorySlot.item: continue
			
			var itemStackGui: ItemStackGui = slots[i].itemStackGui
			if !itemStackGui:
				itemStackGui = ItemStackGuiClass.instantiate()
				slots[i].insert(itemStackGui)
				
			itemStackGui.inventorySlot = inventorySlot
			itemStackGui.update()

func _process(_delta):
	if Input.is_action_just_pressed("inv"):
		if is_open:
			close()
		else:
			open()

func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false

func onSlotClicked(slot):
	if slot.isEmpty(): 
		if !itemInHand: return
		
		insertItemInSlot(slot)
		return
		
	if !itemInHand:
		takeItemFromSlot(slot)
		return
		
	if slot.itemStackGui.inventorySlot.item.name == itemInHand.inventorySlot.item.name:
		stackItems(slot)
		return
	
	swapItems(slot)
	

func takeItemFromSlot(slot):
	itemInHand = slot.takeItem()
	add_child(itemInHand)
	updateItemInHand()

func insertItemInSlot(slot):
	var item = itemInHand
	
	remove_child(itemInHand)
	itemInHand = null
	
	slot.insert(item)

func swapItems(slot):
	var tempItem = slot.takeItem()
	
	insertItemInSlot(slot)
	
	itemInHand = tempItem
	add_child(itemInHand)
	updateItemInHand()

func stackItems(slot):
	var slotItem: ItemStackGui = slot.itemStackGui
	var maxAmount = slotItem.inventorySlot.maxAmountPerStack
	var totalAmount = slotItem.inventorySlot.amount + itemInHand.inventorySlot.amount
	
	if slotItem.inventorySlot.amount == maxAmount:
		swapItems(slot)
		return
	
	if totalAmount <= maxAmount: 
		slotItem.inventorySlot.amount = totalAmount
		remove_child(itemInHand)
		itemInHand = null
	else:
		slotItem.inventorySlot.amount = maxAmount
		itemInHand.inventorySlot.amount = totalAmount - maxAmount
		
	slotItem.update()
	if itemInHand: itemInHand.update()

func updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2.5

func _input(event):
	updateItemInHand()
