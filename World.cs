using Godot;
using System;

public partial class World : Node3D
{
	private Camera3D playerCamera;  // For regular PC camera
	private XRCamera3D xrCamera;   // For XR camera
	private XROrigin3D player;      // The player node containing XRCamera3D and Camera3D

	private float sensitivity = 0.1f;  // Mouse sensitivity for rotation
	private float xRotation = 0f;      // Rotation along X-axis (up/down)
	private float yRotation = 0f;      // Rotation along Y-axis (left/right)

	public override void _Ready()
	{
		// Load the player scene and add it as a child to the current scene
		player = GD.Load<PackedScene>("res://path_to_player_scene.tscn").Instantiate() as XROrigin3D;
		AddChild(player);

		// Get the camera nodes in the player scene
		playerCamera = player.GetNode<Camera3D>("Camera3D");  // Path to Camera3D inside the XROrigin3D
		xrCamera = player.GetNode<XRCamera3D>("XRCamera3D");  // Path to XRCamera3D inside the XROrigin3D

		// Add null checks to ensure the cameras are found
		if (playerCamera == null)
		{
			GD.PrintErr("Player camera not found!");
		}

		if (xrCamera == null)
		{
			GD.PrintErr("XR camera not found!");
		}

		// Set the correct camera
		playerCamera.Show();  // Show the regular camera
		xrCamera.Hide();      // Hide the XR camera

		// Hide and capture the mouse for rotation
		Input.MouseMode = Input.MouseModeEnum.Captured;
	}

	public override void _Process(double delta)
	{
		HandleMouseLook();
	}

	private void HandleMouseLook()
	{
		// Make sure playerCamera is not null before trying to use it
		if (playerCamera != null)
		{
			// Get mouse movement
			Vector2 mouseDelta = Input.GetLastMouseVelocity();

			// Adjust the rotation based on mouse movement and sensitivity
			xRotation -= mouseDelta.Y * sensitivity; // Up/Down rotation
			yRotation -= mouseDelta.X * sensitivity; // Left/Right rotation

			// Clamping the X-axis rotation to avoid over-rotation
			xRotation = Mathf.Clamp(xRotation, -90f, 90f);

			// Rotate the camera
			playerCamera.RotationDegrees = new Vector3(xRotation, yRotation, 0f);
		}
	}
}
