extends Spatial

func get_player():
	return get_child(0).get_child(0).get_node("Player")

func get_screen():
	return get_node("Screen")
	
func get_combatScene():
	return get_node("CombatScene")
	
func getWorldGen():
	return get_node("World/World Generator")
