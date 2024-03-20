extends Node3D

@onready var ball_scene: PackedScene = load("res://ball.tscn")

@export var Camera: Camera3D
@export var Head: Node3D
@export var LeftHand: Node3D
@export var RightHand: Node3D

var grab_damping: float = 0.75
var grab_stiffness: float = 32.0

var local: bool
var fake: bool
var id: String

var left_grabbed_path: NodePath = ""
var right_grabbed_path: NodePath = ""

func _ready():
    add_to_group("networked")

# State passed to the player script when spawned in. For
# this usecase, this just includes the local flag, id for
# the associated player, and global transform (probably the
# location of a spawn point node).
func networked_spawn(state):
    local = state.local
    id = state.id
    global_transform = state.transform

# This is the same state that was returned from
# `networked_process` below for the frame that is being
# rolled back to.
func load_state(state):
    left_grabbed_path = state.left_grabbed_path
    right_grabbed_path = state.right_grabbed_path

# Contains the actual logic for updating the hand mesh
# positions and handle grabbing/spawning balls. Returns any
# state that needs to be reloaded if a rollback occurs. In
# this case that means the path to the currently grabbed
# balls for each hand.
func networked_process():
    var input = SyncManager.input(id)
    if input:
        # if Head:
        #    Head.transform = input.head
        LeftHand.transform = input.left.transform
        LeftHand.scale = Vector3.ONE * (input.left.grip * 0.3 + 0.5)
        RightHand.transform = input.right.transform
        RightHand.scale = Vector3.ONE * (input.right.grip * 0.3 + 0.5)
        
        var tree = get_tree()
        var root = tree.root
        if input.left.grip > 0.5:
            if !left_grabbed_path.is_empty():
                var left_grabbed = get_node(left_grabbed_path)
                var delta = LeftHand.global_position - left_grabbed.global_position
                var acceleration = grab_stiffness * grab_stiffness * delta - 2.0 * grab_damping * grab_stiffness * left_grabbed.linear_velocity()
                acceleration += Vector3.UP * 9.81
                left_grabbed.add_force(acceleration * left_grabbed.mass())
            else:
                var intersecting_bodies = World.bodies_within_sphere(LeftHand.global_position, 0.3)
                if intersecting_bodies.is_empty():
                    var left_grabbed = SyncManager.spawn("ball", root, ball_scene, { "transform": LeftHand.global_transform })
                    left_grabbed_path = left_grabbed.get_path()
                else:
                    left_grabbed_path = intersecting_bodies[0].get_path()
        else:
            left_grabbed_path = ""
            
        if input.right.grip > 0.5:
            if !right_grabbed_path.is_empty():
                var right_grabbed = get_node(right_grabbed_path)
                var delta = RightHand.global_position - right_grabbed.global_position
                right_grabbed.apply_impulse(delta * right_grabbed.mass())
            else:
                var right_grabbed = SyncManager.spawn("ball", root, ball_scene, { "transform": RightHand.global_transform })
                right_grabbed_path = right_grabbed.get_path()
        else:
            right_grabbed_path = ""

    return {
        "left_grabbed_path": left_grabbed_path,
        "right_grabbed_path": right_grabbed_path,
    }
            

# If a fake local player is enabled, move the hands in a
# predictable way since no xr inputs will be available.
var t = 0
func _process(_delta):
    if fake && local:
        t += _delta
        InputManager.set_head_state(Transform3D.IDENTITY.translated(Vector3.UP))
        InputManager.set_hand_state(true, Transform3D.IDENTITY.translated(Vector3(cos(t * 2) * 0.2 - 0.3, sin(t * 2) * 0.2 + 0.5, -0.5)), false, false, 0.0, 0.0, Vector2.ZERO)
        InputManager.set_hand_state(false, Transform3D.IDENTITY.translated(Vector3(cos(-t * 2) * 0.2 + 0.3, sin(-t * 2) * 0.2 + 0.5, -0.5)), false, false, 0.0, 0.0, Vector2.ZERO)

