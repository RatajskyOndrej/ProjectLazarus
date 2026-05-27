extends CharacterBody3D

@onready var los = $LOS
@export var speed: float = 3.0
@export var hp: int = 1 # Základní nepřítel má 1 HP, Tank bude mít v Inspectoru 5
@export var exp_gem_scene: PackedScene = preload("res://exp_gem.tscn") # Výchozí scéna krystalu 

# Automaticky najde hráče v mapě, aby pohyb fungoval bez chyb
@onready var player = get_tree().current_scene.find_child("player", true, false)

func _physics_process(_delta: float) -> void:
	if player:
		# Vypočítáme směr k hráči
		var direction = (player.global_position - global_position).normalized()
		# Zamezíme tomu, aby se nepřítel nakláněl do podlahy nebo vznesl do vzduchu
		direction.y = 0
		
		velocity = direction * speed
		move_and_slide()
		
		# Kontrola nárazu do hráče
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider and collider.name == "player":
				if collider.has_method("take_damage"):
					collider.take_damage(1)
					die() # Při nárazu do hráče hned umře a dropne krystal

# NOVÁ FUNKCE: Kulka teď volá tohle. Ubírá HP a až na nule spustí die()
func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		die()

# Funkce pro zničení nepřítele a dropování odměny
func die():
	# Přidá zářez do počítadla Kills v main.gd
	if get_parent().has_method("add_kill"):
		get_parent().add_kill()
		
	var gem = exp_gem_scene.instantiate()
	
	# OPRAVA: Pozici krystalu musíme nastavit jako místní (position) 
	# a hlavně ještě PŘEDTÍM, než zavoláme call_deferred!
	gem.position = global_position
	gem.position.y = 0.2 
	
	# Teprve teď bezpečně přidáme krystal do mapy
	get_parent().call_deferred("add_child", gem)
	
	queue_free()
