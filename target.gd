extends Node3D

signal popped  # Declare the signal

@export var float_speed: float = 0.4
@export var max_height: float = 2.7  # Despawn height

func _physics_process(delta: float) -> void:
	global_position.y += float_speed * delta

	if global_position.y > max_height:
		queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Balloon being collided! Body: ", body.name, ", Type: ", body.get_class(), ", Position: ", body.global_position)
	
	if body.name.begins_with("Projectile"):
		print("Balloon poked!")
		body.queue_free()
		queue_free()
		emit_signal("popped")  # Let the spawner handle the counter/UI
