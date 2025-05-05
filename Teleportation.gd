extends Area3D

@export var target_scene: PackedScene  # Assign this in the Inspector, or hardcode path

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):  # Make sure your player is in the "player" group
		print("Player entered teleport zone!")
		if target_scene:
			get_tree().change_scene_to_packed(target_scene)
