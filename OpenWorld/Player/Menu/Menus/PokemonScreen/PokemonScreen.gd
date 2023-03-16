extends Node2D


var slotPath = "res://OpenWorld/Player/Menu/Menus/PokemonScreen/PokeSlot.tscn"
onready var pkmnList = get_parent().get_parent().get_parent().playerPokemonList
var startingPos = Vector2(-470, -270)
var space = 100

func _ready():
	for i in range(len(pkmnList)):
		if(str(pkmnList[i]) != ""):
			addSlot(pkmnList[i], Vector2(startingPos.x, startingPos.y+(space*i)))

func addSlot(pokemon, pos):
	var readySlot = load(slotPath).instance()
	readySlot.init(pokemon)
	readySlot.position = pos
	add_child(readySlot)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
