extends Node

var current_input = {
    "head": Transform3D.IDENTITY,
    "left": {
        "transform": Transform3D.IDENTITY,
        "primary": false,
        "secondary": false,
        "grip": 0.0,
        "trigger": 0.0,
        "joy": Vector2.ZERO
    },
    "right": {
        "transform": Transform3D.IDENTITY,
        "primary": false,
        "secondary": false,
        "grip": 0.0,
        "trigger": 0.0,
        "joy": Vector2.ZERO
    }
}

func _ready():
    add_to_group("networked")

func set_head_state(transform):
    current_input.head = transform

func set_hand_state(left_hand: bool, transform: Transform3D, primary: bool, secondary: bool, grip: float, trigger: float, joy: Vector2):
    var state = {
        "transform": transform,
        "primary": primary,
        "secondary": secondary,
        "grip": grip,
        "trigger": trigger,
        "joy": joy
    }
    if left_hand:
        current_input.left = state
    else:
        current_input.right = state

func networked_input():
    return current_input
