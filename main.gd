extends Node3D

func _ready():
	var xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.initialize():
		get_viewport().use_xr = true
