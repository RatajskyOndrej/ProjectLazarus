extends Area3D

# Sem si uložíme hráče, pokud bude stát u stolu
var is_player_nearby: Node3D = null

func _ready() -> void:
	# 🔥 AUTOMATICKÉ PROPOJENÍ: Už žádné klikání v editoru!
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if "has_pistol" in body: # Ověříme, že to, co přišlo ke stolu, je opravdu hráč
		is_player_nearby = body
		print("Jsi u zbraně! Stiskni 'E' pro sebrání.")

func _on_body_exited(body: Node3D) -> void:
	if body == is_player_nearby:
		is_player_nearby = null
		print("Odešel jsi od zbraně.")

func _process(delta: float) -> void:
	# 🔥 UNIVERZÁLNÍ KLÁVESA E: Pokud hráč stojí u stolu a zmáčkne E
	if is_player_nearby and Input.is_action_just_pressed("interact"):
		is_player_nearby.has_pistol = true # Zapneme hráči možnost střílet
		
		# Pokud máš na hráči uzel zbraně (třeba Muzzle), tak ho taky zviditelníme:
		var muzzle_node = is_player_nearby.find_child("Muzzle", true, false)
		if muzzle_node:
			muzzle_node.visible = true
			
		print("Pistole úspěšně sebrána klávesou E!")
		
		# 🔥 OPRAVA: Místo smazání všeho najdeme jen model zbraně a smažeme ten
		# (Zkontroluj v editoru, jestli se ten model zbraně jmenuje přesně "ModelPistole")
		var zbran = find_child("Pistole", true, false)
		if zbran:
			zbran.queue_free()
			
		# Vypneme tuto Area3D, aby už nehledala hráče a nepsala "Stiskni E"
		monitoring = false
		is_player_nearby = null
