extends Node3D

var address: String = ""
var port: String = ""
var startup_action = ""

func _ready():
	var xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.initialize():
		get_viewport().use_xr = true

	SyncManager.connected.connect(_on_sync_manager_connected)
	SyncManager.started.connect(_on_sync_manager_started)

	var args = OS.get_cmdline_user_args()
	var index = 0
	while index < args.size():
		var arg = args[index]
		if arg == "--host":
			startup_action = "host"
		elif arg == "--join":
			startup_action = "join"
		elif arg == "--address":
			index += 1
			arg = args[index]
			address = arg
		elif arg == "--port":
			index += 1
			arg = args[index]
			port = arg
		index += 1

	match startup_action:
		"host":
			SyncManager.host(int(port))
		"join":
			SyncManager.join(address, int(port))

func _on_sync_manager_connected(id):
	print("Player connected! %s" % id)

	if startup_action == "host" || startup_action == "join":
		await get_tree().create_timer(1.0).timeout
		SyncManager.update_ready(true)

func _on_sync_manager_started():
	print("Game Started")
