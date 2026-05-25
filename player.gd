extends CharacterBody3D

# ZMĚNILI JSME CONST NA VAR, ABYCHOM TO MOHLI VYLEPŠOVAT!
var speed = 5.0 
var hp = 3

var shake_intensity = 0.0
var shake_decay = 3.0 # Jak rychle třesení odezní

var current_exp = 0
var level = 1
var exp_to_next_level = 5

var can_shoot = true
var fire_rate = 0.5 

@onready var hp_label = $"%HPLabel"
@onready var level_label = $"%LevelLabel"
@onready var bullet_scene = preload("res://bullet.tscn")
@onready var muzzle = $Muzzle

# OPRAVENÉ NAČTENÍ: Hledáme okno přímo přes složku UI
@onready var upgrade_panel = $"../UI/UpgradePanel"
@onready var speed_button = $"../UI/UpgradePanel/SpeedButton"
@onready var fire_rate_button = $"../UI/UpgradePanel/FireRateButton"
@onready var heal_button = $"../UI/UpgradePanel/HealButton"


func _ready() -> void:
	if hp_label:
		hp_label.text = "HP: " + str(hp)
	if level_label:
		level_label.text = "LvL: " + str(level) + " (" + str(current_exp) + "/" + str(exp_to_next_level) + ")"
		
	# TATO KONTROLA NÁM ŘEKNE PRAVDU:
	if upgrade_panel:
		print("SUPER: Hráč úspěšně našel UpgradePanel!")
	else:
		print("CHYBA: Hráč stále nemůže najít UpgradePanel. Zkontroluj, zda se jmenuje přesně takto a je uvnitř UI.")
		
	if speed_button: speed_button.pressed.connect(upgrade_speed)
	if fire_rate_button: fire_rate_button.pressed.connect(upgrade_fire_rate)
	if heal_button: heal_button.pressed.connect(upgrade_heal)

func _physics_process(delta: float) -> void:
	# PRIDÁME TENTO ŘÁDEK SEM NA ZAČÁTEK:
	var camera = get_viewport().get_camera_3d()

	# --- 1. POHYB HRÁČE ---
	var input_dir := Input.get_vector("move_left", "move_right", "move_foreward", "move_back")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# --- EFEKT TŘESENÍ KAMERY ---
	if shake_intensity > 0:
		shake_intensity = move_toward(shake_intensity, 0, shake_decay * delta)
		if camera:
			camera.h_offset = randf_range(-shake_intensity, shake_intensity)
			camera.v_offset = randf_range(-shake_intensity, shake_intensity)
	elif camera:
		camera.h_offset = 0
		camera.v_offset = 0
		
	if direction:
		velocity.x = direction.x * speed # Zde se teď používá malá proměnná speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	# --- 2. MÍŘENÍ ZA MYŠÍ ---
	camera = get_viewport().get_camera_3d()
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
	if Input.is_action_pressed("shoot") and can_shoot:
		can_shoot = false 
		
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_transform = muzzle.global_transform
		
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true 

# --- 4. ZRANĚNÍ A SMRT ---
func take_damage(amount: int) -> void:
	hp -= amount
	shake_intensity = 0.4 # Tímto spustíme otřes obrazovky!

	if hp_label: hp_label.text = "HP: " + str(hp)
	if hp <= 0: die()

func die() -> void:
	print("GAME OVER!")
	get_tree().reload_current_scene()

# --- 5. ZKUŠENOSTI A LEVELOVÁNÍ ---
func gain_exp(amount: int) -> void:
	current_exp += amount
	if current_exp >= exp_to_next_level:
		level_up()
	if level_label:
		level_label.text = "LvL: " + str(level) + " (" + str(current_exp) + "/" + str(exp_to_next_level) + ")"

func level_up() -> void:
	level += 1
	current_exp -= exp_to_next_level 
	exp_to_next_level = int(exp_to_next_level * 1.5) + 5
	
	if level_label:
		level_label.text = "LvL: " + str(level) + " (" + str(current_exp) + "/" + str(exp_to_next_level) + ")"
	
	# VYVOLÁNÍ MENU A PAUZA
	if upgrade_panel:
		upgrade_panel.show()
		get_tree().paused = true

# --- 6. UPGRADE FUNKCE Z TLAČÍTEK ---
func resume_game() -> void:
	if upgrade_panel:
		upgrade_panel.hide()
	get_tree().paused = false # Konec pauzy

func upgrade_speed() -> void:
	speed += 1.0 # Zrychlíme hráče
	resume_game()

func upgrade_fire_rate() -> void:
	fire_rate = max(0.1, fire_rate - 0.1) # Zrychlíme střelbu (menší prodleva, minimum 0.1s)
	resume_game()

func upgrade_heal() -> void:
	hp += 1 # Přidáme život
	if hp_label: hp_label.text = "HP: " + str(hp)
	resume_game()
