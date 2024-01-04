extends Control


var slotPath = "res://Scenes/2DScreens/PokemonScreen/PokeSlot.tscn"
var startingPos = Vector2(-577, -298)
var space = 110

@onready var slots = $Slots

func loadPokemon(pokemonList):
	for node in slots.get_children():
		node.queue_free()
	
	for i in range(len(pokemonList)):
		if(str(pokemonList[i]) != ""):
			addSlot(pokemonList[i], Vector2(startingPos.x, startingPos.y+(space*i)))

func addSlot(pokeLoad, pos):
	var readySlot = load(slotPath).instantiate()
	readySlot.init(pokeLoad)
	readySlot.position = pos
	slots.add_child(readySlot)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
