extends Node3D

@onready var player_puppet_scene: PackedScene = load("res://puppet.tscn")
@onready var xr_origin = $/root/Main/XROrigin3D

var address: String = ""
var port: String = ""
# Default action is to run locally
var startup_action = "local"

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
        "local":
            SyncManager.update_ready(true)

func _on_sync_manager_connected(id):
    print("Player connected! %s" % id)

    if startup_action == "host" || startup_action == "join":
        await get_tree().create_timer(1.0).timeout
        SyncManager.update_ready(true)

func _on_sync_manager_started():
    var tree = get_tree()
    var root = tree.root
    var spawn_points = tree.get_nodes_in_group("SpawnPoints")
    var local_id = SyncManager.local_id()
    var player_index = 0

    for id in SyncManager.ids():
        var spawn_point = spawn_points[player_index]
        if id == SyncManager.local_id():
            xr_origin.transform = spawn_point.global_transform
            xr_origin.local = true
            xr_origin.id = id
        else:
            var state = { "id": id, "local": id == local_id, "transform": spawn_point.global_transform }
            SyncManager.spawn("PlayerPuppet", root, player_puppet_scene, state)

        player_index += 1
