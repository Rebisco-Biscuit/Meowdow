extends Button

var hit_time := 0.0
var tolerance := 0.2
var manager = null

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	manager.register_hit(self)
