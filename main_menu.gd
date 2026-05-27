extends Control

func _ready() -> void:
	# Ujistíme se, že hra není zapauzovaná (kdybychom se vraceli z Game Over)
	get_tree().paused = false

func _on_story_button_pressed() -> void:
	# Zatím jen změníme text tlačítka, aby hráč věděl
	$VBoxContainer/StoryButton.text = "Story Mode (Coming Soon!)"

func _on_endless_button_pressed() -> void:
	# Spustí naši hlavní hru!
	get_tree().change_scene_to_file("res://main.tscn")
