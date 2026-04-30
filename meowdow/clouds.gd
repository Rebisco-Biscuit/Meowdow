extends ParallaxBackground

@onready var cloud1 = $Cloud1
@onready var cloud2 = $Cloud2

var speed = 20.0

func _process(delta):
	cloud1.position.x += speed * delta
	cloud2.position.x += speed * delta

	# wrap each one individually
	if cloud1.position.x >= 1420.5:
		cloud1.position.x = -1421.

	if cloud2.position.x >= 1420.8:
		cloud2.position.x = -1420.5
