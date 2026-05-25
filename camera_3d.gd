extends Camera3D

# Zde je upravené malé "p", aby to přesně sedělo na tvůj uzel
@onready var target = $"../player"
var offset = Vector3(0, 6, 4) 

func _process(_delta):
	if target:
		global_position = target.global_position + offset
