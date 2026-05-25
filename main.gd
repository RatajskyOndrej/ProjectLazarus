extends Node3D

# Rozdělíme si nepřátele, abychom s nimi mohli lépe pracovat podle času
@onready var enemy_basic = preload("res://enemy.tscn")
@onready var enemy_fast = preload("res://enemy_fast.tscn")
@onready var enemy_tank = preload("res://enemy_tank.tscn")

@onready var spawners = $Spawners.get_children()
@onready var spawn_timer = $SpawnTimer 

var game_time = 0.0
var kills = 0

@onready var timer_label = $"%TimerLabel"
@onready var kills_label = $"%KillsLabel"

func _ready() -> void:
	update_ui()

func _process(delta: float) -> void:
	if not get_tree().paused:
		game_time += delta
		update_ui()
		
		# Pozvolné zrychlování spawnu
		var new_spawn_rate = max(0.2, 2.0 - (game_time / 30.0) * 0.3)
		if spawn_timer:
			spawn_timer.wait_time = new_spawn_rate

func _on_spawn_timer_timeout() -> void:
	# 1. Na začátku hry se smí spawnovat jen malí a rychlí
	var allowed_enemies = [enemy_basic, enemy_fast]
	
	# 2. Teprve po 45 vteřinách přidáme do osudí těžkého Tanka
	if game_time >= 45.0:
		allowed_enemies.append(enemy_tank)
	
	# Náhodný výběr pouze z povolených nepřátel
	var random_enemy_scene = allowed_enemies.pick_random()
	var enemy = random_enemy_scene.instantiate()
	
	var random_spawner = spawners.pick_random()
	enemy.global_position = random_spawner.global_position
	add_child(enemy)

func add_kill():
	kills += 1
	update_ui()

func update_ui():
	var minutes = int(game_time) / 60
	var seconds = int(game_time) % 60
	
	if timer_label:
		timer_label.text = "Time: %02d:%02d" % [minutes, seconds]
	if kills_label:
		kills_label.text = "Kills: " + str(kills)
