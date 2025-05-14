extends Node

@export var spawner: Node
@export var victory_model: Node3D  # Pre-existing victory model in the scene
@export var defeat_model: Node3D  # Pre-existing defeat model in the scene
@export var player_camera: XRCamera3D  # Assign your player camera in the Inspector
@export var victory_mesh_instance: MeshInstance3D  # Explicitly assign MeshInstance3D for victory model
@export var defeat_mesh_instance: MeshInstance3D  # Explicitly assign MeshInstance3D for defeat model
@export var game_over_board: Node3D

func _ready():
	# Rename the mesh instances to make them distinguishable
	if defeat_mesh_instance:
		defeat_mesh_instance.name = "DefeatMeshInstance"
	if victory_mesh_instance:
		victory_mesh_instance.name = "VictoryMeshInstance"
	
	spawner.connect("game_over", Callable(self, "_on_game_over"))

func _on_game_over(popped_count: int):
	print("🎮 Game Over! Balloons popped: ", popped_count)

	# Pause the entire game
	#get_tree().paused = true

	# Determine the result model based on the popped count
	var result_model: Node3D =  victory_model if popped_count >= 10 else defeat_model
	var result_mesh_instance: MeshInstance3D = defeat_mesh_instance if popped_count >= 10 else victory_mesh_instance
	print("🧩 Selected result_mesh_instance:", result_mesh_instance, " → Source: ", "defeat_mesh_instance" if popped_count >= 10 else "victory_mesh_instance")


	if result_model and result_mesh_instance:
		# Ensure the model is visible
		result_model.visible = true

		# Set the result model to process always
		#result_model.process_mode = Node3D.PROCESS_MODE_ALWAYS

		# Position the result model in front of the player's camera
		if player_camera:
			var distance = 2.6
			var forward = -player_camera.global_transform.basis.z
			forward.x = 0  # Ignore tilt
			forward = forward.normalized()

			var new_position = player_camera.global_transform.origin + forward * distance
			new_position.y = 0.1  # Maintain consistent height

			result_model.global_transform.origin = new_position
			result_model.look_at(player_camera.global_transform.origin, Vector3.UP)
			result_model.rotate_y(deg_to_rad(180))
			result_model.rotate_x(deg_to_rad(-30))

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
		
		# Show and update the GameOverBoard
		if game_over_board:
			game_over_board.visible = true

			var balloon_label = game_over_board.get_node_or_null("BalloonCount") as Label3D
			if balloon_label:
				balloon_label.text = "You poked %d balloons!" % popped_count

			var win_label = game_over_board.get_node_or_null("WinLabel") as Label3D
			var lose_label = game_over_board.get_node_or_null("LoseLabel") as Label3D

			if win_label:
				win_label.visible = popped_count > 5
			if lose_label:
				lose_label.visible = popped_count <= 5
		
	else:
		print("❌ Result model or MeshInstance3D not found.")
