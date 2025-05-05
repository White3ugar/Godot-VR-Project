extends CollisionShape3D

@export var ground_y_threshold: float = 0.4  # Adjust as needed for your ground level

func _on_timer_timeout() -> void:
	queue_free()

func _physics_process(delta: float) -> void:
	if global_position.y <= ground_y_threshold:
		print("Projectile hit the ground, deleting.")
		queue_free()
