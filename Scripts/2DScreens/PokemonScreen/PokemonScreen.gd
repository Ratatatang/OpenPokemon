extends Control


var slotPath = "res://Scenes/2DScreens/PokemonScreen/PokeSlot.tscn"
var startingPos = Vector2(-577, -268)
var space = 100

@onready var emptySlot = load("res://Scenes/2DScreens/PokemonScreen/EmptyPokeSlot.tscn")
@onready var slots = $Slots

func loadPokemon(pokemonList):
	for node in slots.get_children():
		node.queue_free()
	
	var counter = 0
	
	for i in range(len(pokemonList)):
		counter += 1
		if(str(pokemonList[i]) != ""):
			addSlot(pokemonList[i], Vector2(startingPos.x, startingPos.y+(space*i)))
	
	if(counter - 6 == 0):
		return
	
	for i in (6-counter):
		var slot = emptySlot.instantiate()
		slot.position = Vector2(startingPos.x, startingPos.y+(space*(i+counter)))
		slots.add_child(slot)

func addSlot(pokeLoad, pos):
	var readySlot = load(slotPath).instantiate()
	readySlot.init(pokeLoad)
	readySlot.position = pos
	slots.add_child(readySlot)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
