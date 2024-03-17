extends XRCamera3D

func _process(delta):
    InputManager.set_head_state(position)
