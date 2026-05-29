extends CanvasLayer

func _ready() -> void:
	# Když se obrazovka ukáže, pozastavíme celou hru, ať nepřátelé dál neběhají
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	# Hlídá stisk klávesy R (v Godotu je to KEY_R)
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_R):
		#🔥 Odpauzujeme hru a bleskově restartujeme aktuální level
		get_tree().paused = false
		get_tree().reload_current_scene()
