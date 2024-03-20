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
