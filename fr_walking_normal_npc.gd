extends AnimatedSprite2D

@export var speed: float = 50# 🔧 Lower speed for testing
@export var sprite_scene: PackedScene
@export var follow_path: NodePath  # ✅ Must point to your actual Path2D

@onready var path_follow = get_parent() as PathFollow2D

var travel_time := 0.0
var parent_rotation



func _ready():
	play()
	show()
	path_follow.loop = true
	set_process(true)
	print("✅ READY")

	start_spawn_sequence()  # Begin delayed spawn

func _process(delta):
	travel_time += delta
	path_follow.progress += speed * delta
	parent_rotation = get_parent().rotation
	rotation = -parent_rotation

# 💡 Starts everything after original moves a bit
func start_spawn_sequence():
	await get_tree().create_timer(2.0).timeout  # Wait 2 seconds
	print("⏱️ Clone wave starting...")

	spawn_wave(2, 2.0)  # First wave: 2 clones, 2 sec apart

	await get_tree().create_timer(2.0 * 2 + 6).timeout  # Wait for wave to finish + 6 sec
	spawn_wave(2, 2.5)  # Second wave: 2 clones, 2.5 sec apart


# 💥 Spawns a wave of clones with delays
func spawn_wave(count: int, delay: float):
	print("🚀 Spawning wave:", count, "with delay:", delay)
	for i in range(count):
		await get_tree().create_timer(delay * i).timeout
		print("⏳ Spawning clone", i + 1)
		spawn_clone()

# 👤 Makes 1 clone and attaches to Path2D
func spawn_clone():
	if sprite_scene == null:
		push_error("❌ sprite_scene not assigned! Assign it in the Inspector.")
		return

	print("📦 Creating clone...")

	var new_follow = PathFollow2D.new()
	var new_sprite = sprite_scene.instantiate() as AnimatedSprite2D

	new_follow.loop = true
	new_follow.progress = path_follow.progress  # instead of 0.0

	new_follow.name = "CloneFollow"
	new_follow.add_child(new_sprite)

	var path = get_node_or_null(follow_path)
	if path and path is Path2D:
		path.add_child(new_follow)
		print("✅ Clone added to path")
	else:
		push_error("❌ Path2D not found! follow_path was: %s" % follow_path)
# Optional: hide the original sprite
func hide_original():
	hide()
