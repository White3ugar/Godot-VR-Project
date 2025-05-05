extends Node3D

@export var balloon_scene: PackedScene
@export var balloon_ui: CanvasLayer
@export var platform_node: Node3D  # The platform node (e.g., a MeshInstance3D or CollisionShape3D)
@export var spawn_height: float  # The fixed height of the spawn (y position)
@export var spawn_interval: float 
@export var wand: Node3D  # The wand reference

var platform_size: Vector2
var spawn_timer_started: bool = false

func _ready():
	print("Spawner is ready.")
	
	# Get platform size (width and depth)
	var collision_shape = platform_node.get_node("CollisionShape3D")
	if collision_shape and collision_shape.shape is BoxShape3D:
		var box_shape = collision_shape.shape
		platform_size = Vector2(box_shape.extents.x * 2, box_shape.extents.z * 2)  # Get width and depth
		print("Platform size: ", platform_size)
	else:
		print("No CollisionShape3D or invalid shape.")
	
	# Ensure spawn timer is not started yet
	$SpawnTimer.stop()
	print("SpawnTimer has not started.")

	# Connect signals from wand (the wand reference must be assigned in the Inspector)
	wand.connect("wand_picked_up", Callable(self, "_on_wand_grabbed"))
	wand.connect("wand_dropped", Callable(self, "_on_wand_dropped"))

# Called when wand is grabbed
func _on_wand_grabbed() -> void:
	if not spawn_timer_started:
		print("Wand grabbed! Starting spawn timer.")
		$SpawnTimer.wait_time = spawn_interval
		$SpawnTimer.start()  # Start the spawn timer
		print("Wand grabbed! Starting Stop spawn timer.")
		$StopSpawnTimer.start()
		spawn_timer_started = true
		
	# Show the balloon UI
	if balloon_ui:
		print("Wand grabbed! Set balloon ui visible")
		balloon_ui.visible = true

# Called when wand is dropped
func _on_wand_dropped() -> void:
	pass

func _spawn_balloon():
	print("Attempting to spawn balloon...")
	if balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)

		# Assign the UI reference directly
		balloon.balloon_ui = balloon_ui

		# Random spawn position within platform
		var random_x = randf_range(-platform_size.x / 2, platform_size.x / 2)
		var random_z = randf_range(-platform_size.y / 2, platform_size.y / 2)
		var spawn_position = Vector3(random_x, spawn_height, random_z)

		balloon.global_position = spawn_position
		print("Balloon spawned at position: ", spawn_position)
	else:
		print("No balloon scene assigned.")
# Called when the spawn timer reaches its timeout
func _on_spawn_timer_timeout() -> void:
	print("SpawnTimer timeout reached.")
	_spawn_balloon()

# Optional: If you want to stop the timer at some point using another timer
func _on_StopSpawnTimer_timeout() -> void:
	print("StopSpawnTimer timeout reached. Stopping SpawnTimer.")
	$SpawnTimer.stop()
