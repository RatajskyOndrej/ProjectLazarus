extends CharacterBody3D

const SPEED = 3.0

@onready var exp_gem_scene = preload("res://exp_gem.tscn")

@onready var player = $"/root/Main/player" 

func _physics_process(_delta: float) -> void:
	if player:
		# Vypočítáme směr k hráči
		var direction = (player.global_position - global_position).normalized()
		# Zamezíme tomu, aby se nepřítel nakláněl do podlahy nebo vznesl do vzduchu
		direction.y = 0
		
		velocity = direction * SPEED
		move_and_slide()
		
		
		
# Funkce, kterou může kdokoliv zavolat, aby nepřítele zničil
func die():
	# Vytvoříme krystal a dáme ho do hlavní scény
	var gem = exp_gem_scene.instantiate()
	get_tree().current_scene.add_child(gem)

	# Krystal položíme přesně tam, kde právě umřel nepřítel
	gem.global_position = global_position

	# Smažeme nepřítele
	queue_free()
	
