extends XRController3D

@onready var mesh = $Mesh

# Called when the node enters the scene tree for the first time.
func _ready():
	input_float_changed.connect(_on_input_float_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(global_position)


func _on_input_float_changed(name, value):
	print(name, value) # Replace with function body.
	if name == "grip":
		if value >= 0:
			mesh.scale = Vector3.ONE * (1 + value)
		else:
			mesh.scale = Vector3.ONE
	
