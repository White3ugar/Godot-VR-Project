extends Node3D

@export var balloon_scene: PackedScene
@export var platform_node: Node3D
@export var spawn_height: float
@export var spawn_interval: float
@export var wand: Node3D
@export var notice_board_node: Node3D
@export var notice_board_label: Label3D 

var platform_size: Vector2
var spawn_timer_started: bool = false
var popped_count: int = 0
var countdown_time: int = 30  # seconds
var countdown_timer: Timer

signal game_over(popped_count: int)

func _ready():
	print("Spawner is ready.")

	var collision_shape = platform_node.get_node("CollisionShape3D")
	if collision_shape and collision_shape.shape is BoxShape3D:
		var box_shape = collision_shape.shape
		platform_size = Vector2(box_shape.extents.x * 2, box_shape.extents.z * 2)
	else:
		print("No valid CollisionShape3D found.")

	$SpawnTimer.stop()
	$StopSpawnTimer.stop()

	# Setup countdown timer
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0
	countdown_timer.one_shot = false
	countdown_timer.timeout.connect(_on_countdown_tick)
	add_child(countdown_timer)

	# Connect wand signals
	wand.connect("wand_picked_up", Callable(self, "_on_wand_grabbed"))
	wand.connect("wand_dropped", Callable(self, "_on_wand_dropped"))

	# Get the Label3D node from the already instanced NoticeBoard
	if notice_board_label:
		print("NoticeBoard label found: " + notice_board_label.name)
	else:
		print("⚠️ NoticeBoard label not assigned in the Inspector!")
		
func _on_wand_grabbed():
	if not spawn_timer_started:
		print("Wand grabbed! Starting balloon spawning and countdown.")
		$SpawnTimer.wait_time = spawn_interval
		$SpawnTimer.start()
		$StopSpawnTimer.start()
		countdown_time = 30
		popped_count = 0
		countdown_timer.start()
		spawn_timer_started = true
		_update_notice_label()

func _on_wand_dropped():
	# Optional: You can stop timers here if needed
	pass

func _spawn_balloon():
	print("Spawning balloon...")
	if balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.global_position = Vector3(
			randf_range(-platform_size.x / 2, platform_size.x / 2),
			spawn_height,
			randf_range(-platform_size.y / 2, platform_size.y / 2)
		)
		# Connect to balloon's "popped" signal if exists
		
		if balloon.has_signal("popped"):
			print("Call the signal POPPED from target scene")
			balloon.connect("popped", Callable(self, "_on_balloon_popped"))
	else:
		print("No balloon scene assigned.")

func _on_spawn_timer_timeout():
	_spawn_balloon()

func _on_StopSpawnTimer_timeout():
	print("StopSpawnTimer timeout reached. Stopping spawn timer.")
	$SpawnTimer.stop()

func _on_balloon_popped():
	popped_count += 1
	_update_notice_label()

func _on_countdown_tick():
	countdown_time -= 1
	_update_notice_label()
	if countdown_time <= 0:
		countdown_timer.stop()
		$SpawnTimer.stop()
		print("Countdown finished!")
		
		# Emit the signal and pass the score
		emit_signal("game_over", popped_count)

func _update_notice_label():
	if notice_board_label:
		notice_board_label.text = "🎈 Balloons Popped: %d\n\n⏳ Time Left: %ds" % [popped_count, countdown_time]
	else:
		print("⚠️ Notice board label not assigned!")
