extends Area3D

func _ready() -> void:
	# Krystal čeká, až se ho dotkne hráč
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "player":
		# Zeptáme se, jestli umí hráč sbírat expy
		if body.has_method("gain_exp"):
			body.gain_exp(1) # Přidáme hráči 1 bod zkušeností
		queue_free() # Krystal zmizí (sebrali jsme ho)
