extends Camera3D

@export var camera_height: float = 12.0

# Nastavení taktického předsunutí
@export var look_ahead_factor: float = 0.20 # Jak moc kamera následuje myš (0.20 je ideální decentní posun)
@export var max_shift: float = 3.0          # Maximální vzdálenost v metrech, kam až se kamera může odchýlit
@export var smooth_speed: float = 4.0       # Rychlost, jakou se vyhlazuje POUZE posun myši

@onready var player = get_tree().current_scene.find_child("player", true, false)

# Sem si budeme ukládat samostatný posun myši
var current_shift: Vector3 = Vector3.ZERO

func _process(delta: float) -> void:
	if player:
		# 1. Výpočet, kam přesně na podlaze ukazuje kurzor myši
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = project_ray_origin(mouse_pos)
		var ray_normal = project_ray_normal(mouse_pos)
		
		var plane = Plane(Vector3.UP, player.global_position)
		var intersection = plane.intersects_ray(ray_origin, ray_normal)
		
		var target_shift = Vector3.ZERO
		
		if intersection:
			# Zjistíme směr a vzdálenost od hráče k myši
			var offset = intersection - player.global_position
			target_shift = offset * look_ahead_factor
			
			# Omezíme maximální posun, aby myš nevytáhla kameru z mapy
			if target_shift.length() > max_shift:
				target_shift = target_shift.normalized() * max_shift
		
		# 2. 🔥 TAJNÁ INGREDIENCE: Vyhlazujeme POUZE posun myši, pohyb hráče ignorujeme!
		current_shift = current_shift.lerp(target_shift, smooth_speed * delta)
		
		# 3. Finální pozice: Pozice hráče (1:1 bez jakéhokoliv lagování) + plynulý posun myši
		global_position.x = player.global_position.x + current_shift.x
		global_position.z = player.global_position.z + current_shift.z
		global_position.y = camera_height
		
		# 4. ZÁMEK ROTACE: Pohled kolmo dolů
		global_rotation_degrees = Vector3(-90, 0, 0)
