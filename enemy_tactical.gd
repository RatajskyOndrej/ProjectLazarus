extends CharacterBody3D

@onready var nav_agent = $NavAgent
@onready var los = $LOS
@export var speed: float = 3.0
@export var hp: int = 1
# Zapne režim nehybného terče na střelnici
@export var is_static_target: bool = false

# 🔥 Nastavení šířky kuželu tvé baterky (0.7 = cca 90 stupňů, 0.5 = cca 120 stupňů)
@export var vision_cone_threshold: float = 0.6

var last_known_position: Vector3 = Vector3.ZERO
var tracking_player: bool = false

@onready var player = get_tree().current_scene.find_child("player", true, false)

func _physics_process(delta: float) -> void:
	$MeshInstance3D.visible = false
	
	if is_static_target:
		$MeshInstance3D.visible = true
		return 
		
	if player:
		# 
		if global_position.distance_to(player.global_position) < 1.2:
			if player.has_method("die"):
				player.die()
				return # Ukončí pohyb, už tě zabil
				
		# --- Zbytek je detekce zraku pomocí paprsku ---
		los.global_position = global_position + Vector3(0, 1.0, 0)
		los.target_position = los.to_local(player.global_position + Vector3(0, 1.0, 0))
		los.force_raycast_update()
		
		var can_see_player = false
		if los.is_colliding():
			var collider = los.get_collider()
			if collider == player:
				var player_forward = -player.global_transform.basis.z.normalized() 
				var dir_to_enemy = (global_position - player.global_position).normalized() 
				
				if player_forward.dot(dir_to_enemy) > vision_cone_threshold:
					can_see_player = true
		
		# STAV A: Osvícen baterkou
		if can_see_player:
			$MeshInstance3D.visible = true 
			last_known_position = player.global_position
			tracking_player = true
			
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			nav_agent.target_position = player.global_position
			
			var next_path_position = nav_agent.get_next_path_position()
			var direction = (next_path_position - global_position)
			direction.y = 0 # 🔥 OPRAVA: I tady nesmí vrtat do podlahy!
			velocity = direction.normalized() * speed
			
		# STAV B: Hledá podle sluchu nebo staré pozice
		elif tracking_player:
			nav_agent.target_position = last_known_position
			
			if global_position.distance_to(last_known_position) < 1.0:
				tracking_player = false
				velocity = Vector3.ZERO
			else:
				var next_path_position = nav_agent.get_next_path_position()
				var direction = (next_path_position - global_position)
				direction.y = 0 
				direction = direction.normalized()
				if direction.length() > 0.1:
					look_at(Vector3(next_path_position.x, global_position.y, next_path_position.z), Vector3.UP)
				velocity = direction * speed
		else:
			velocity = Vector3.ZERO
			
		move_and_slide()

func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		die()

func die():
	if get_parent().has_method("add_kill"):
		get_parent().add_kill()
	queue_free()
