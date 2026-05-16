extends CanvasLayer

@onready var ItemStackGuiClass = preload("res://inventory/itemStackGui.tscn")

var inventory: Inv:
	set(value):
		inventory = value

		if inventory == null:
			print("[SHOP] Inventory is null")
			return

		if inventory.slots == null:
			print("[SHOP] Inventory.slots is null")
			return

		if not inventory.updated.is_connected(refresh_slots):
			inventory.updated.connect(refresh_slots)

		refresh_slots()

# slots
@onready var slots = $Inv/GridContainer.get_children()

# info panel
@onready var item_texture = $SellInfo/MarginContainer/VBoxContainer/NinePatchRect/ItemTexture
@onready var item_name = $SellInfo/MarginContainer/VBoxContainer/ItemName
@onready var quantity_label = $SellInfo/MarginContainer/VBoxContainer/HBoxContainer/Quantity
@onready var total_label = $SellInfo/MarginContainer/VBoxContainer/HBoxContainer2/Amount

# buttons
@onready var add_button = $SellInfo/MarginContainer/VBoxContainer/HBoxContainer/AddButton
@onready var subtract_button = $SellInfo/MarginContainer/VBoxContainer/HBoxContainer/SubtractButton
@onready var sell_button = $SellInfo/MarginContainer/VBoxContainer/SellButton
@onready var close_button = $CloseButton

var selected_slot: InventorySlot = null
var sell_quantity := 1
var selected_price := 0


func _ready():
	add_button.pressed.connect(_on_add_pressed)
	subtract_button.pressed.connect(_on_subtract_pressed)
	sell_button.pressed.connect(_on_sell_pressed)
	close_button.pressed.connect(_on_close_pressed)

	connect_slots()
	clear_selection()


func connect_slots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		slot.pressed.connect(_on_slot_pressed.bind(i))


func refresh_slots():
	if inventory == null or inventory.slots == null or slots == null:
		return

	for i in range(min(inventory.slots.size(), slots.size())):
		var inv_slot: InventorySlot = inventory.slots[i]

		if not inv_slot.item:
			slots[i].clear()
			continue

		var itemStackGui: ItemStackGui = slots[i].itemStackGui
		if not itemStackGui:
			itemStackGui = ItemStackGuiClass.instantiate()
			slots[i].insert(itemStackGui)

		itemStackGui.inventorySlot = inv_slot
		itemStackGui.update()
		
		var sprite = itemStackGui.get_node_or_null("item_display")
		if sprite:
			sprite.scale = Vector2(4.0, 4.0)  # tweak this value

		var label = itemStackGui.get_node_or_null("Label")
		if label:
			label.scale = Vector2(3.25, 4)  # tweak separately to your liking


func _on_slot_pressed(index):
	if inventory == null:
		return

	if index >= inventory.slots.size():
		return

	var slot = inventory.slots[index]

	if slot.item == null:
		return

	selected_slot = slot
	sell_quantity = 1

	item_texture.texture = slot.item.texture
	item_name.text = slot.item.name
	selected_price = slot.item.price

	update_sell_info()


func update_sell_info():
	if selected_slot == null:
		return

	quantity_label.text = str(sell_quantity)
	total_label.text = str(selected_price * sell_quantity) + " $"


func _on_add_pressed():
	if selected_slot == null:
		return

	if sell_quantity < selected_slot.amount:
		sell_quantity += 1

	update_sell_info()


func _on_subtract_pressed():
	if selected_slot == null:
		return

	if sell_quantity > 1:
		sell_quantity -= 1

	update_sell_info()


func _on_sell_pressed():
	if selected_slot == null:
		return

	var item_name = selected_slot.item.name.to_lower()

	for i in range(sell_quantity):
		inventory.remove(selected_slot.item)

	GlobalData.catnips += selected_price * sell_quantity
	_reduce_crop_count(item_name, sell_quantity)

	inventory.updated.emit()
	refresh_slots()
	clear_selection()


func _reduce_crop_count(item_name: String, amount: int):
	match item_name:
		"carrot":
			GlobalData.gigglegrain_count = max(0, GlobalData.gigglegrain_count - amount)
		"corn":
			GlobalData.wheepingwheat_count = max(0, GlobalData.wheepingwheat_count - amount)
		"beetroot":
			GlobalData.snowbloom_count = max(0, GlobalData.snowbloom_count - amount)
		"berries":
			GlobalData.frostbell_count = max(0, GlobalData.frostbell_count - amount)
		"strawberry":
			GlobalData.gloomberry_count = max(0, GlobalData.gloomberry_count - amount)
		"tomato":
			GlobalData.rhomato_count = max(0, GlobalData.rhomato_count - amount)


func clear_selection():
	selected_slot = null
	item_texture.texture = null
	item_name.text = "No item selected"
	quantity_label.text = "0"
	total_label.text = "0 $"


func _on_close_pressed():
	queue_free()
