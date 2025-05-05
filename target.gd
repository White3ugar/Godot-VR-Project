extends Node3D

@export var float_speed: float = 0.4
@export var max_height: float = 2.7  # Despawn height
var balloon_ui: CanvasLayer

func _physics_process(delta: float) -> void:
	global_position.y += float_speed * delta

	if global_position.y > max_height:
		queue_free()
	
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Balloon being collided! Body: ", body.name, ", Type: ", body.get_class(), ", Position: ", body.global_position)
	if body.name.begins_with("Projectile"):
		print("Balloon poked!")
		body.queue_free()
		queue_free()

		# Update the UI counter
		if balloon_ui and balloon_ui.has_method("increment_count"):
			print("Balloon counter + 1!")
			balloon_ui.increment_count()
