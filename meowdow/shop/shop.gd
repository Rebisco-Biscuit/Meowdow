extends CanvasLayer

signal closed

@onready var grid: GridContainer = $Panel/VBoxContainer/GridContainer
@onready var catnip_label: Label = $Panel/CatnipLabel

var font = preload("res://assets/Minecraft.ttf")

var shop_items = [
	preload("res://shop/shop_carrot_seed.tres"),
	preload("res://shop/shop_corn_seed.tres"),
	preload("res://shop/shop_beetroot_seed.tres"),
	preload("res://shop/shop_berries_seed.tres"),
	preload("res://shop/shop_tomato_seed.tres"),
	preload("res://shop/shop_strawberry_seed.tres"),
]

func _ready():
	populate_grid()
	update_catnip_label()

func populate_grid():
	for child in grid.get_children():
		child.queue_free()

	# --- Shared StyleBoxFlat for icon background ---
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = Color("#DCB98A")
	icon_style.corner_radius_top_left = 8
	icon_style.corner_radius_top_right = 8
	icon_style.corner_radius_bottom_left = 8
	icon_style.corner_radius_bottom_right = 8

	var font_color = Color("#c4a27e")

	for shop_item in shop_items:
		var is_locked = shop_item.locked and GlobalData.current_map != shop_item.unlock_map

		# --- Outer container per item ---
		var container = VBoxContainer.new()
		container.alignment = BoxContainer.ALIGNMENT_CENTER
		container.custom_minimum_size = Vector2(80, 110)
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# --- Icon Button ---
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(64, 64)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.disabled = is_locked
		btn.add_theme_stylebox_override("normal", icon_style)
		btn.add_theme_stylebox_override("hover", icon_style)
		btn.add_theme_stylebox_override("pressed", icon_style)
		btn.add_theme_stylebox_override("disabled", icon_style)

		if shop_item.icon:
			btn.icon = shop_item.icon
			btn.expand_icon = true

		if is_locked:
			btn.tooltip_text = "Unlock %s map first" % shop_item.unlock_map.capitalize()
		else:
			btn.tooltip_text = shop_item.item_name

		btn.pressed.connect(_on_item_pressed.bind(shop_item))
		container.add_child(btn)

		# --- Item name ---
		var name_label = Label.new()
		name_label.text = shop_item.item_name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.vertical_alignment =VERTICAL_ALIGNMENT_CENTER		
		name_label.add_theme_font_override("font", font)
		name_label.add_theme_font_size_override("font_size", 18)
		name_label.add_theme_color_override("font_color", font_color)
		name_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		container.add_child(name_label)

		# --- Price ---
		var price_label = Label.new()
		price_label.text = "$" + str(shop_item.price)
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		price_label.vertical_alignment =VERTICAL_ALIGNMENT_CENTER		
		price_label.add_theme_font_override("font", font)		
		price_label.add_theme_font_size_override("font_size", 18)
		price_label.add_theme_color_override("font_color", font_color)
		price_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		container.add_child(price_label)

		if is_locked:
			container.modulate = Color(0.5, 0.5, 0.5, 1.0)

		grid.add_child(container)
func _on_item_pressed(shop_item: ShopItem):
	
	if GlobalData.quest_step == 1:
		GlobalData.quest_step = 2	
	
	if GlobalData.catnips < shop_item.price:
		print("Not enough catnips!")
		return

	var inventory = GlobalData.get_player_inventory()
	if inventory == null:
		return

	var seed = shop_item.item_scene.instantiate()
	if seed.get("item") != null:
		inventory.insert(seed.item)
		GlobalData.catnips -= shop_item.price
		update_catnip_label()
		print("Bought: ", shop_item.item_name)
	seed.queue_free()

func update_catnip_label():
	catnip_label.text = "$" + str(GlobalData.catnips)

func _on_close_button_pressed():
	closed.emit()
	queue_free()
