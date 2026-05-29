extends CharacterBody3D

# 🔥 TADY JE TA ZMĚNA: Načteme přesně tvůj funkční projektil, který používáš ty pro hráče!
# (Pokud se tvoje scéna jmenuje bullet.tscn, nech to tak. Pokud tracer.tscn, přepiš to na tracer.tscn)
const BULLET_SCENE = preload("res://tracer.tscn")

@onready var muzzle = $Muzzle
@onready var nav_agent = $NavAgent

@export var speed: float = 3.0
@export var hp: int = 1
@export var is_static_target: bool = false
@export var vision_cone_threshold: float = 0.6
@export var is_shooter: bool = false

var time_in_sight: float = 0.0 
var shoot_cooldown: float = 0.0 
var last_known_position: Vector3 = Vector3.ZERO
var tracking_player: bool = false

@onready var player = get_tree().current_scene.find_child("player", true, false)

func _physics_process(delta: float) -> void:
	if shoot_cooldown > 0:
		shoot_cooldown -= delta
		
	$MeshInstance3D.visible = false
	
	if is_static_target:
		$MeshInstance3D.visible = true
		return 
		
	if player:
		# Běžec tě zabije dotykem, střelec ne
		if not is_shooter and global_position.distance_to(player.global_position) < 1.5:
			if player.has_method("die"):
				player.die()
				return 

		# Spolehlivé zjišťování viditelnosti přes fyziku světa
		var space_state = get_world_3d().direct_space_state
		var start_pos = global_position + Vector3(0, 0.5, 0)
		var end_pos = player.global_position + Vector3(0, 0.5, 0)
		
		var query = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
		query.exclude = [get_rid()]
		
		var result = space_state.intersect_ray(query)
		var can_see_player = false
		
		if result and result.collider == player:
			var player_forward = -player.global_transform.basis.z.normalized() 
			var dir_to_enemy = (global_position - player.global_position).normalized() 
			
			if player_forward.dot(dir_to_enemy) > vision_cone_threshold:
				can_see_player = true
					
		# Nepřítel tě vidí
		if can_see_player:
			$MeshInstance3D.visible = true
			last_known_position = player.global_position
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
			if is_shooter:
				velocity = Vector3.ZERO
				time_in_sight += delta
				
				# Výstřel po 0.75 vteřině
				if time_in_sight >= 0.75 and shoot_cooldown <= 0:
					shoot_bullet()
					shoot_cooldown = 1.5 
			else:
				tracking_player = true
				time_in_sight = 0.0
				
				nav_agent.target_position = player.global_position
				var next_path_position = nav_agent.get_next_path_position()
				var direction = (next_path_position - global_position)
				direction.y = 0 
				velocity = direction.normalized() * speed
				
		# Hráč zmizel za zdí
		else:
			$MeshInstance3D.visible = false
			velocity = Vector3.ZERO
			time_in_sight = 0.0 
			
			if tracking_player and not is_shooter:
				nav_agent.target_position = last_known_position
				if global_position.distance_to(last_known_position) < 1.0:
					tracking_player = false 
				else:
					var next_path_position = nav_agent.get_next_path_position()
					var direction = (next_path_position - global_position)
					direction.y = 0 
					velocity = direction.normalized() * speed
					if direction.length() > 0.1:
						look_at(Vector3(next_path_position.x, global_position.y, next_path_position.z), Vector3.UP)
			else:
				tracking_player = false
			
		move_and_slide()

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	if get_parent().has_method("add_kill"):
		get_parent().add_kill()
	queue_free()

func shoot_bullet() -> void:
	if not player: return

	# 1. Spawne se úplně stejná scéna, jakou střílíš ty
	var bullet_instance = BULLET_SCENE.instantiate()
	
	# Označíme ji, že letí od nepřítele, aby nezabila jeho, ale tebe
	if "shot_by_enemy" in bullet_instance:
		bullet_instance.shot_by_enemy = true
		
	get_tree().current_scene.add_child(bullet_instance)
	
	# 2. Dáme ji na hlaveň a namíříme na tebe
	bullet_instance.global_position = muzzle.global_position
	var target_pos = player.global_position + Vector3(0, 0.5, 0)
	bullet_instance.look_at(target_pos, Vector3.UP)
	
	# Okamžitá a spravedlivá smrt hráče
	if player.has_method("die"):
		player.die()
