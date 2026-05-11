extends CanvasLayer

@onready var texture_rect: TextureRect = $TextureRect
@onready var anim: AnimationPlayer = $AnimationPlayer

var slides = [
	preload("res://assets/screen/m30w.png"),
	preload("res://assets/screen/meowdow.png"),
]

var current_slide := 0

func _ready():
	anim.animation_finished.connect(_on_animation_finished)
	show_slide(0)

func show_slide(index: int):
	texture_rect.texture = slides[index]
	anim.play("fade_in")

func _on_animation_finished(anim_name: String):
	if anim_name == "fade_in":
		await get_tree().create_timer(0.9).timeout
		anim.play("fade_out")
	elif anim_name == "fade_out":
		current_slide += 1
		if current_slide < slides.size():
			show_slide(current_slide)
		else:
			get_tree().change_scene_to_file("res://MainMenu.tscn")
