extends CanvasLayer

func _ready():
	$SkipButton.pressed.connect(_on_skip_pressed)

func _on_skip_pressed():
	if Dialogic.current_timeline != null:
		Dialogic.end_timeline()
	queue_free()
