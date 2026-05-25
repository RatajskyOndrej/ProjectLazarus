extends Area3D

@export var exp_amount: int = 1 

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("gain_exp"):
		body.gain_exp(exp_amount)
		queue_free() # Krystal zmizí
