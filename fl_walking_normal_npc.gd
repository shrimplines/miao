extends AnimatedSprite2D

@export var speed: float = 650
@export var sprite_scene: PackedScene
@export var follow_path: NodePath

@onready var path_follow = get_parent() as PathFollow2D

var travel_time := 0.0
var parent_rotation

func _ready():
	play()
	show()
	path_follow.loop = true
	set_process(true)

	# Original starts moving right away.
	start_spawn_sequence()

func _process(delta):
	travel_time += delta
	path_follow.progress += speed * delta
	parent_rotation = get_parent().rotation
	rotation = -parent_rotation

# Orchestrates everything in order
func start_spawn_sequence():
	await get_tree().create_timer(2.0).timeout  # Wait before clones start

	spawn_wave(2, 2.0)  # First wave: 3 clones, 2 sec apart

	# Wait for the first wave (2.0 * 3) + 7 seconds before second wave
	await get_tree().create_timer(2.0 * 2 + 7).timeout
	spawn_wave(2, 2.5)  # Second wave: 2 clones, 2.5 sec apart

func spawn_wave(count: int, delay: float):
	for i in range(count):
		await get_tree().create_timer(delay * i).timeout
		spawn_clone()

func spawn_clone():
	if sprite_scene == null:
		push_error("sprite_scene is not assigned! Assign it in the Inspector.")
		return

	print("⏳")

	var new_follow = PathFollow2D.new()
	var new_sprite = sprite_scene.instantiate() as AnimatedSprite2D

	new_follow.loop = true
	new_follow.progress = 0.0
	new_follow.name = "CloneFollow"
	new_follow.add_child(new_sprite)

	var path = get_node_or_null(follow_path)
	if path and path is Path2D:
		path.add_child(new_follow)  # ✅ Add to the actual path, not to this node
		print("✅")
	else:
		push_error("Could not find Path2D at: %s" % follow_path)

func hide_original():
	hide()  # Optional: call this if you want to hide the original sprite

