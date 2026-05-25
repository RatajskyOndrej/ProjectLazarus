extends Node3D

# Načteme si scénu nepřítele
@onready var enemy_scene = preload("res://enemy.tscn")
# Získáme seznam všech markerů, co jsme rozestavili
@onready var spawners = $Spawners.get_children()

func _on_spawn_timer_timeout() -> void:
	# Vytvoříme novou kopii nepřítele
	var enemy = enemy_scene.instantiate()
	
	# Vybereme náhodný bod z našich markerů
	var random_spawner = spawners.pick_random()
	
	# Nastavíme pozici nepřítele na tento vybraný bod
	enemy.global_position = random_spawner.global_position
	
	# Přidáme nepřítele do hry
	add_child(enemy)
