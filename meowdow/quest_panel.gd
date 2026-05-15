extends CanvasLayer

@onready var quest_list: VBoxContainer = $PanelContainer/VBoxContainer/QuestList
var font = preload("res://assets/Minecraft.ttf")

# --- TOWN 1: Vinalore (steps 0-8) ---
const TOWN1_QUESTS = [
	{"step": 0, "text": "Find Luna the merchant"},
	{"step": 1, "text": "Buy Gigglegrain seeds from Luna"},
	{"step": 2, "text": "Find the field and plant a Gigglegrain (F)"},
	{"step": 3, "text": "Harvest 100 Gigglegrains (%d/100)"},
	{"step": 4, "text": "Talk to Dewpaw"},
	{"step": 5, "text": "Plant the Wheepingwheat seed (F)"},
	{"step": 6, "text": "Harvest the Wheepingwheat"},
	{"step": 7, "text": "Talk to Old Jerry"},
	{"step": 8, "text": "Find a statue to travel to Aubrialis"},
]

# --- TOWN 2: Aubrialis (steps 9-14) ---
const TOWN2_QUESTS = [
	{"step": 9,  "text": "Talk to the NPC Guide"},
	{"step": 10, "text": "Talk to Frostcribe"},
	{"step": 11, "text": "Talk to Thaaw"},
	{"step": 12, "text": "Plant 150 Frostbell & 150 Snowbloom (%d/150 | %d/150)"},
	{"step": 13, "text": "Talk to Thaaw again"},
	{"step": 14, "text": "Show the Thawbloom to Frostcribe"},
	{"step": 15, "text": "Find a statue to travel to Rhollow"},
]

# --- TOWN 3: Rhollow (steps 15+) ---
const TOWN3_QUESTS = [
	{ "step": 16, "text": "Talk to the NPC Guide in Rhollow" },
	{ "step": 17, "text": "Find Glow (the black cat)" },
	{ "step": 18, "text": "Plant and harvest Gloomberries (F)" },
	{ "step": 19, "text": "Enter the dungeon and face Echofall" },
	{ "step": 20, "text": "Defeat Echofall" },
	{ "step": 21, "text": "Talk to the Entity in the dungeon" },
	{ "step": 22, "text": "Plant the Seed of Rhomato (F)" },
	{ "step": 23, "text": "Talk to Echofall — rewrite the ending" },
	{ "step": 24, "text": "The End" },	
]

func _ready():
	refresh()

func get_active_quests() -> Array:
	var step = GlobalData.quest_step

	# Show only current town's quests
	if step <= 8:
		return TOWN1_QUESTS
	elif step <= 15:
		return TOWN2_QUESTS
	else:
		return TOWN3_QUESTS

func refresh():
	for child in quest_list.get_children():
		child.queue_free()

	var active_quests = get_active_quests()

	for quest in active_quests:
		# Only show quests up to current step
		if quest["step"] > GlobalData.quest_step:
			continue

		var label = Label.new()
		var text = quest["text"]

		# Inject progress counters
		match quest["step"]:
			3:
				text = text % GlobalData.gigglegrain_count
			12:
				text = "Plant 150 Frostbell & 150 Snowbloom (%d/150 | %d/150)" % [GlobalData.frostbell_count, GlobalData.snowbloom_count]
			18:
				text = "Plant and harvest Gloomberry (%d/1) (F)" % GlobalData.gloomberry_count
			22:
				text = "Plant the Seed of Rhomato (%d/1) (F)" % GlobalData.rhomato_count
	
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
