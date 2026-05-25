extends CharacterBody3D

const SPEED = 5.0
var hp = 3

@onready var hp_label = $"%HPLabel"
@onready var bullet_scene = preload("res://bullet.tscn")
@onready var muzzle = $Muzzle

func _ready() -> void:
	# Nastaví správný text životů hned při spuštění hry
	if hp_label:
		hp_label.text = "Zivoty: " + str(hp)

func _physics_process(_delta: float) -> void:
	# --- 1. POHYB HRÁČE ---
	var input_dir := Input.get_vector("move_left", "move_right", "move_foreward", "move_back")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# --- 2. MÍŘENÍ ZA MYŠÍ ---
	var camera = get_viewport().get_camera_3d()
	if camera:
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_normal = camera.project_ray_normal(mouse_pos)
		
		var plane = Plane(Vector3.UP, global_position)
		var intersection = plane.intersects_ray(ray_origin, ray_normal)
		
		if intersection:
			if intersection.distance_to(global_position) > 0.1:
				var target_look = Vector3(intersection.x, global_position.y, intersection.z)
				look_at(target_look, Vector3.UP)
				
	# --- 3. STŘÍLENÍ ---
	if Input.is_action_just_pressed("shoot"):
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_transform = muzzle.global_transform

# --- 4. ZRANĚNÍ A SMRT ---
func take_damage(amount: int) -> void:
	hp -= amount
	
	# Aktualizuje text na obrazovce
	if hp_label:
		hp_label.text = "HP: " + str(hp)
	
	if hp <= 0:
		die()

func die() -> void:
	print("GAME OVER!")
	get_tree().reload_current_scene()
