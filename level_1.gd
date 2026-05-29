extends Node3D

var targets_destroyed: int = 0

func _ready() -> void:
	print("Training started. Destroy 3 targets to proceed!")

func add_kill() -> void:
	targets_destroyed += 1
	print("Total kills: ", targets_destroyed)
	
	var objective_label = find_child("ObjectiveLabel", true, false)
	
	# --- FÁZE 1: STŘELNICE (3 cíle) ---
	if targets_destroyed <= 3:
		if objective_label:
			objective_label.text = "Objective: Destroy targets (" + str(targets_destroyed) + "/3)"
		
		if targets_destroyed == 3:
			print("Tutorial complete! Opening door...")
			if objective_label:
				# 🔥 Nastavíme text pro bludiště (0 z 5)
				objective_label.text = "Objective: Clear the maze (0/5)"
			
			var tutorial_door = find_child("TutorialDoor", true, false)
			if tutorial_door:
				tutorial_door.queue_free()

	# --- FÁZE 2: LABYRINT (3 terče + 5 nepřátel = celkem 8 killů) ---
	elif targets_destroyed > 3 and targets_destroyed <= 8:
		# Spočítáme, kolik z těch 5 v bludišti už hráč dostal
		var maze_kills = targets_destroyed - 3
		if objective_label:
			objective_label.text = "Objective: Clear the maze (" + str(maze_kills) + "/5)"
			
		if targets_destroyed == 8:
			print("Maze cleared! Opening both maze doors...")
			if objective_label:
				objective_label.text = "Objective: Secure the rooms!"
				
			# Najde a smaže první dveře
			var maze_door = find_child("MazeDoor", true, false)
			if maze_door:
				maze_door.queue_free()
				
			# Najde a smaže druhé dveře
			var maze_door_2 = find_child("MazeDoor2", true, false)
			if maze_door_2:
				maze_door_2.queue_free()
