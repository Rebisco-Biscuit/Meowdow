extends Node2D

@onready var base_wall_tilemap = $BaseWallTileMap
@onready var active_wall_tilemap = $ActiveWallTileMap

@onready var expansion_2 = $Expansions/ExpansionLevel2
@onready var expansion_3 = $Expansions/ExpansionLevel3
@onready var expansion_4 = $Expansions/ExpansionLevel4


func _ready():
	# Initialize game properly
	copy_base_to_active()
	set_house_level(1)


func _input(event):
	if event.is_action_pressed("ui_2"):
		set_house_level(2)
	elif event.is_action_pressed("ui_3"):
		set_house_level(3)
	elif event.is_action_pressed("ui_4"):
		set_house_level(4)


# ---------------------------------------------------
# CORE FUNCTION: SET HOUSE LEVEL
# ---------------------------------------------------
func set_house_level(level: int):

	# STEP 1: ALWAYS RESET FROM BASE
	copy_base_to_active()

	# STEP 2: RESET VISUAL EXPANSIONS
	expansion_2.visible = false
	expansion_3.visible = false
	expansion_4.visible = false

	# STEP 3: APPLY UPGRADES IN ORDER
	if level >= 2:
		expansion_2.visible = true
		apply_level_2()

	if level >= 3:
		expansion_3.visible = true
		apply_level_3()

	if level >= 4:
		expansion_4.visible = true
		apply_level_4()


# ---------------------------------------------------
# COPY BASE → ACTIVE (CRITICAL CORE SYSTEM)
# ---------------------------------------------------
func copy_base_to_active():

	active_wall_tilemap.clear()

	for cell in base_wall_tilemap.get_used_cells():

		active_wall_tilemap.set_cell(
			cell,
			base_wall_tilemap.get_cell_source_id(cell),
			base_wall_tilemap.get_cell_atlas_coords(cell)
		)


# ---------------------------------------------------
# EXPANSION 2
# (30,25) → (41,25)
# ---------------------------------------------------
func apply_level_2():
	for x in range(30, 42):
		active_wall_tilemap.erase_cell(Vector2i(x, 25))


# ---------------------------------------------------
# EXPANSION 3
# (30,21) → (41,21)
# ---------------------------------------------------
func apply_level_3():
	for x in range(30, 42):
		active_wall_tilemap.erase_cell(Vector2i(x, 21))


# ---------------------------------------------------
# EXPANSION 4
# (41,18) → (41,26)
# ---------------------------------------------------
func apply_level_4():
	for y in range(18, 27):
		active_wall_tilemap.erase_cell(Vector2i(41, y))
