# Untitled VR Game

Goal: Make a VR game in godot where you can throw a physics
ball between two players.

## Current Setup

Godot has autoloads which are singleton nodes that are
configured to load on startup. Current we use three:

- `SyncManager`: The main coordinator for rollback
  networking. It is defined in
  `./gdrollback/src/sync_manager.rs`. More details on it's
  usage can be found here: https://github.com/Kethku/gdrollback

  The important pieces for the current project are that it
  will call `network_process` and `load_state` on any nodes
  that are in the `networked` group. It also has a `spawn`
  function on it which spawns scenes in a way that works
  with the rollback system.
- `InputManager`: The node which the sync_manager uses to
  retrieve input from the local player. It is defined in
  `./autoloads/InputManagerAL.gd`.
- `World`: The node that contains the physics world. It is
  defined in `./gdrapier3d/src/world.rs`.

## Startup Flow

`main.gd` is attached to the root of the default scene and
is responsible for setting up the `SyncManager` and starting
the game loop. On startup, `_ready` is called which hooks up
event callbacks from the `SyncManager`, parses command line
arguments to decide whether to start as a host or client,
and sets up the player scene either as a puppet or xr
origin.

After connected to the remote player, the
`_on_sync_manager_started` callback is called which moves
the player to one of the positions defined nodes in the
`SpawnPoints` group, and spawns remote player puppets for
the other connected peers.

## `main.tscn`

The main scene contains `R3DRigidBody` nodes for the floor,
and stack of boxes, environment information to facilitate
rendering, and a series of `Node3D` spawn point nodes to 
define where players should spawn.

The `R3DRigidBody` nodes automatically get added to the 
`World` autoload when they are added to the tree (in this
case on startup). There are `R3DCuboidColliders` and
`MeshInstance3D` nodes as children for each of the boxes which
also get automatically registered to their parent in the
physics system. No code is necessary to network these
objects beyond their base types.

## `Player.gd`

The majority of the actual logic in the current setup is
defined in `Player.gd` which is responsible for updating the
player hand and head mesh positions, and processing local
input to spawn balls and update their positions while
grabbed by the player.

Since the spawned ball objects are `R3DRigidBody` nodes, we
can use the functions on them like `add_force`,
`apply_impulse` etc to move them around.
