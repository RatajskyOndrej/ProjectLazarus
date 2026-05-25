extends Camera3D

# Odkaz na hráče. Godot ho najde v hlavní scéně podle jména.
@onready var player = $"/root/Main/Player" 

# Jak moc má být kamera posunutá od hráče (výška a vzdálenost)
var offset = Vector3(0, 10, 8) 
# Rychlost plynulého dojezdu (vyšší číslo = rychlejší sledování)
var smoothness = 5.0 

func _physics_process(delta):
	if player:
		# Spočítáme, kde by kamera MĚLA být
		var target_position = player.global_position + offset
		# Plynule posuneme kameru z aktuální pozice do cílové pozice
		global_position = global_position.lerp(target_position, smoothness * delta)
