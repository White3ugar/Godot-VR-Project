extends XRToolsPickable

#@export var balloon_spawner: Node3D  # Reference to the Balloon Spawner
@export var projectile: PackedScene
@export var projectile_speed: float = 10.0
var projectile_count = 0  

var can_fire = true

# Define custom signals to notify the spawner
signal wand_picked_up
signal wand_dropped

func action():
	super.action()  # Call parent class method

	if can_fire:
		_spawn_bullet()
		can_fire = false
		$Cooldown.start()

func _spawn_bullet():
	if projectile:
		var new_projectile: RigidBody3D = projectile.instantiate()
		if new_projectile:
			projectile_count += 1
			new_projectile.name = "Projectile_%d" % projectile_count  # Give it a unique name that starts with "Projectile"

			add_child(new_projectile)
			new_projectile.global_transform = $SpawnPoint.global_transform
			new_projectile.linear_velocity = -new_projectile.global_transform.basis.z * projectile_speed

func _on_cooldown_timeout() -> void:
	can_fire = true

func _on_picked_up(pickable: Variant) -> void:
	print("Wand was picked up")
	emit_signal("wand_picked_up")  # Emit custom signal when picked up


func _on_dropped(pickable: Variant) -> void:
	print("Wand was dropped")
	emit_signal("wand_dropped")  # Emit custom signal when dropped
