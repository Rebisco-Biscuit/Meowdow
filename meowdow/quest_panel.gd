extends CanvasLayer

@onready var quest_list: VBoxContainer = $PanelContainer/VBoxContainer/QuestList
var font = preload("res://assets/Minecraft.ttf")

const QUESTS = [
	{
		"step": 0,
		"text": "Find Luna the merchant"
	},
	{
		"step": 1,
		"text": "Buy carrot seeds from Luna"
	},
	{
		"step": 2,
		"text": "Find the field and plant a carrot (F)"
	},
	{
		"step": 3,
		"text": "Harvest 3 carrots (%d/3)"
	},
	{
		"step": 4,
		"text": "Talk to Dewpaw"
	},
	{
		"step": 5,
		"text": "Plant the Wheepingwheat (corn) seed (F)"
	},
	{
		"step": 6,
		"text": "Harvest the Wheepingwheat"
	},
	{
		"step": 7,
		"text": "Talk to Old Jerry"
	},
	{
		"step": 8,
		"text": "Find a statue to travel to Aubrialis"
	},
]

func _ready():
	refresh()

func refresh():
	for child in quest_list.get_children():
		child.queue_free()

	for quest in QUESTS:
		# Only show quests up to current step + 1 ahead
		if quest["step"] > GlobalData.quest_step:
			continue

		var label = Label.new()
		var text = quest["text"]

		# Inject progress counter for carrot quest
		if quest["step"] == 3:
			text = text % GlobalData.gigglerain_count

		var is_done = GlobalData.quest_step > quest["step"]

		if is_done:
			label.text = text
			label.modulate = Color(0.6, 0.6, 0.6, 1.0)
		else:
			label.text = text
			label.modulate = Color(1.0, 1.0, 1.0, 1.0)

		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_font_override("font", font)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.custom_minimum_size = Vector2(180, 0)
		quest_list.add_child(label)

func _process(_delta):
	refresh()
