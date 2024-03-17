extends Node3D

@onready var ball_scene: PackedScene = load("res://ball.tscn")

@export var Head: Node3D
@export var LeftHand: Node3D
@export var RightHand: Node3D

var grab_damping: float = 0.75
var grab_stiffness: float = 32.0

var local: bool
var id: String

var left_grabbed: R3DRigidBody
var right_grabbed: R3DRigidBody

func _ready():
    add_to_group("networked")

func networked_spawn(state):
    local = state.local
    id = state.id
    global_transform = state.transform

func networked_process():
    var input = SyncManager.input(id)
    if input:
        if Head:
            Head.transform = input.head
        LeftHand.transform = input.left.transform
        LeftHand.scale = Vector3.ONE * (input.left.grip * 0.3 + 0.5)
        RightHand.transform = input.right.transform
        RightHand.scale = Vector3.ONE * (input.right.grip * 0.3 + 0.5)
        
        var tree = get_tree()
        var root = tree.root
        if input.left.grip > 0.5:
            if left_grabbed && is_instance_valid(left_grabbed):
                var delta = LeftHand.global_position - left_grabbed.global_position
                var acceleration = grab_stiffness * grab_stiffness * delta - 2.0 * grab_damping * grab_stiffness * left_grabbed.linear_velocity()
                acceleration += Vector3.UP * 9.81
                left_grabbed.add_force(acceleration * left_grabbed.mass())
            else:
                var intersecting_bodies = World.bodies_within_sphere(LeftHand.global_position, 0.3)
                if intersecting_bodies.is_empty():
                    left_grabbed = SyncManager.spawn("ball", root, ball_scene, { "transform": LeftHand.global_transform })
                else:
                    left_grabbed = intersecting_bodies[0]
        else:
            left_grabbed = null
            
        if input.right.grip > 0.5:
            if right_grabbed && is_instance_valid(right_grabbed):
                var delta = RightHand.global_position - right_grabbed.global_position
                right_grabbed.apply_impulse(delta * right_grabbed.mass())
            else:
                right_grabbed = SyncManager.spawn("ball", root, ball_scene, { "transform": RightHand.global_transform })
        else:
            right_grabbed = null
            
