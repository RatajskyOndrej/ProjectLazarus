extends Area3D

const SPEED = 25.0

func _ready() -> void:
	# PŘIDÁNO: Řekneme kulce, aby zavolala funkci _on_body_entered, když do něčeho narazí
	body_entered.connect(_on_body_entered)
	
	# Původní časovač na smazání po 2 vteřinách letu
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_translate(-global_transform.basis.z * SPEED * delta)

# NOVÉ: Co se stane při nárazu
func _on_body_entered(body: Node3D) -> void:
	# 1. Ignorujeme hráče
	if body.name == "player":
		return 
		
	# 2. Zeptáme se, jestli to, do čeho jsme narazili, má funkci "die"
	if body.has_method("die"):
		body.die() # Pokud ano, zavoláme ji (nepřítel se zničí)
		
	# 3. Kulička zničí samu sebe
	queue_free()
		
	# Pokud kulička zasáhne objekt ve skupině "enemy"
	if body.is_in_group("enemy"):
		body.queue_free() # Smažeme nepřítele
		
	# Nakonec smažeme samotnou kuličku (ať už trefila zeď nebo nepřítele)
	queue_free()
