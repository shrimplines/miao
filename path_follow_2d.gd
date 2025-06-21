extends PathFollow2D

@export var speed: float = 70

func _process(delta):
	progress += speed * delta
