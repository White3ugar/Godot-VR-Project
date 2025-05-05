extends Node3D

var interface: XRInterface

func _ready() -> void:
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.initialize():
		print("OpenXR initialized successfully!")
		XRServer.primary_interface = interface
		get_viewport().use_xr = true
	else:
		print("Failed to initialize OpenXR.")
