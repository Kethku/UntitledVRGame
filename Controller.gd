extends XRController3D

@export var Left: bool

var grip: float
var trigger: float
var joy: Vector2
var primary_button: bool
var secondary_button: bool

func _ready():
    button_pressed.connect(_on_button_pressed)
    button_released.connect(_on_button_released)
    input_float_changed.connect(_on_input_float_changed)
    input_vector2_changed.connect(_on_input_vector2_changed)

func _process(delta):
    InputManager.set_hand_state(Left, transform, primary_button, secondary_button, grip, trigger, joy)

func _on_button_pressed(name):
    match name:
        "ax_button":
            primary_button = true
        "by_button":
            secondary_button = true
    
func _on_button_released(name):
    match name:
        "ax_button":
            primary_button = false
        "by_button":
            secondary_button = false

func _on_input_float_changed(name, value):
    match name:
        "grip":
            grip = value
        "trigger":
            trigger = value

func _on_input_vector2_changed(name, value):
    match name:
        "primary":
            joy = value
