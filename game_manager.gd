extends Node

@export var spawner: Node
@export var victory_model: Node3D  # Pre-existing victory model in the scene
@export var defeat_model: Node3D  # Pre-existing defeat model in the scene
@export var player_camera: XRCamera3D  # Assign your player camera in the Inspector
@export var victory_mesh_instance: MeshInstance3D  # Explicitly assign MeshInstance3D for victory model
@export var defeat_mesh_instance: MeshInstance3D  # Explicitly assign MeshInstance3D for defeat model


func _ready():
	spawner.connect("game_over", Callable(self, "_on_game_over"))

func _on_game_over(popped_count: int):
	print("🎮 Game Over! Balloons popped: ", popped_count)

	# Pause the entire game
	get_tree().paused = true

	# Determine the result model based on the popped count
	var result_model: Node3D = defeat_model if popped_count >= 1 else victory_model
	var result_mesh_instance: MeshInstance3D = defeat_mesh_instance if popped_count >= 10 else victory_mesh_instance

	if result_model and result_mesh_instance:
		# Ensure the model is visible
		result_model.visible = true

		# Set the result model to process always
		result_model.process_mode = Node3D.PROCESS_MODE_ALWAYS

		# Position the result model in front of the player's camera
		if player_camera:
			var distance = 2.6  # Distance in front of the camera
			var forward = -player_camera.global_transform.basis.z.normalized()
			var new_position = player_camera.global_transform.origin + forward * distance

			# Set the y-axis to always be 0.5
			new_position.y = 0.5

			result_model.global_transform.origin = new_position
			result_model.look_at(player_camera.global_transform.origin, Vector3.UP)
			result_model.rotate_y(deg_to_rad(180))

		# Play animation if available
		var anim_player = result_model.get_node_or_null("AnimationPlayer")
		if anim_player:
			anim_player.process_mode = Node3D.PROCESS_MODE_ALWAYS
			var animations = anim_player.get_animation_list()
			if animations.size() > 0:
				anim_player.play(animations[1])  # Play the first animation
				print("▶️ Playing animation:", animations[1])
			else:
				print("⚠️ No animations found in AnimationPlayer.")
		else:
			print("❌ AnimationPlayer not found in result model.")
	else:
		print("❌ Result model or MeshInstance3D not found.")
