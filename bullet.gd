extends Area3D

const SPEED = 25.0
var damage: int = 1 # NOVÉ: Každá kulka teď dává poškození za 1 HP

func _ready() -> void:
	# Řekneme kulce, aby zavolala funkci _on_body_entered, když do něčeho narazí
	body_entered.connect(_on_body_entered)
	
	# Časovač na smazání po 2 vteřinách letu, ať kulky nelétají do nekonečna mapou
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_translate(-global_transform.basis.z * SPEED * delta)

# Co se stane při nárazu
func _on_body_entered(body: Node3D) -> void:
	# 1. Ignorujeme hráče (nechceme zastřelit sami sebe při spawnu kulky)
	if body.name == "player":
		return 
		
	# 2. ZMĚNA: Místo okamžité smrti zavoláme novou funkci take_damage a předáme jí sílu rány
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
	# 3. Kulička po nárazu zničí samu sebe (ať už trefila nepřítele, nebo překážku)
	queue_free()
