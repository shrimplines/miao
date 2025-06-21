extends PathFollow2D

@export var speed: float = 70

func _ready():
	get_node("AnimatedSprite2D").play()

func _process(delta):
	progress += speed * delta
