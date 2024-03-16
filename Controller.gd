extends XRController3D

@onready var mesh = $Mesh

func _ready():
	input_float_changed.connect(_on_input_float_changed)

func _on_input_float_changed(name, value):
	if name == "grip":
		if value >= 0:
			mesh.scale = Vector3.ONE * (1 + value)
		else:
			mesh.scale = Vector3.ONE
	
