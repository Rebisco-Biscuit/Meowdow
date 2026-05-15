extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var prompt = $Prompt

var player = null

# --- Idle animation ---
var idle_timer := 0.0
var idle_interval := 5.0

# --- Items that count as sellable crops ---
const CROP_NAMES = ["carrot", "corn", "beetroot", "berries", "tomato", "strawberry"]

func _ready():
	prompt.visible = false
	randomize()

func _process(delta):
	# --- Prompt animation ---
	if prompt.visible:
		prompt.position.y = -5 + sin(Time.get_ticks_msec() * 0.005) * 3

	# --- Idle animation ---
	idle_timer += delta
	if idle_timer >= idle_interval:
		sprite.play("default")
		idle_timer = 0.0
		idle_interval = randf_range(4.0, 7.0)

	# --- Interaction ---
	if player and Input.is_action_just_pressed("interact"):
		sell_all_crops()

# --- Sell all crops in inventory ---
func sell_all_crops():
	if player == null:
		return

	var inventory: Inv = player.inventory
	if inventory == null:
		print("No inventory found on player.")
		return

	var total_catnips := 0
	var total_sold := 0

	for slot in inventory.slots:
		if slot.item == null:
			continue

		# Check if this item is a crop by name
		var item_name = slot.item.name.to_lower()
		var is_crop = CROP_NAMES.any(func(crop): return item_name.contains(crop))

		if is_crop:
			var amount = slot.amount
			for i in range(amount):
				total_catnips += randi_range(5, 10)
			total_sold += amount
			slot.item = null
			slot.amount = 0

	if total_sold == 0:
		print("No crops to sell!")
		return

	inventory.updated.emit()
	GlobalData.catnips += total_catnips
	# After selling
	get_tree().get_root().get_node("Aubrialis").update_catnip_label()
	print("Sold %d crops for %d catnips! Total: %d" % [total_sold, total_catnips, GlobalData.catnips])

# --- Interaction zone signals ---
func _on_interaction_zone_body_entered(body):
	if body is CharacterBody2D:
		player = body
		if not prompt.visible:
			prompt.visible = true

func _on_interaction_zone_body_exited(body):
	if body is CharacterBody2D:
		player = null
		prompt.visible = false
