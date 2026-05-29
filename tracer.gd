extends Area3D # Pozor, nahoře musí být Area3D, ne Node3D!

const SPEED = 60.0

func _ready() -> void:
	# Pojistka: Smaže se za 2 vteřiny, jen kdyby letěla do nebe
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_translate(-global_transform.basis.z * SPEED * delta)

# 🔥 TOTO ZASTAVÍ KULKU O ZEĎ
func _on_body_entered(body: Node3D) -> void:
	# Pokud trefíš nepřítele (a má funkci take_damage), dá mu to damage
	if body.has_method("take_damage"):
		body.take_damage(1) 
		
	# Ať už trefí nepřítele, nebo zadní zeď, okamžitě se zničí!
	queue_free()
