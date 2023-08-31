extends Node3D

@export var validSpawns = {100: ["Bulbasaur"]}
@export var validAlphas = {100: ["Bulbasaur"]}

var runReady = true
var dominantPokemon

@export var maxPokemon = 1
var linkedPokemon

func _ready():
	if(runReady):
	#$Nest_Zone/CollisionShape.scale.x = round(rand_range(1, 6))
	#$Nest_Zone/CollisionShape.scale.z = round(rand_range(1, 6))
		var pokeList = decidePokemon()
		
		for p in pokeList:
			var num = randf_range(0, p.size()-1)
			spawnPokemon(p[num])

func decidePokemon():
	var pokeList = []
	
	var keys = validSpawns.keys()
	keys.sort()
	
	for i in range(round(randf_range(1, maxPokemon))):
		var num = randf_range(0, 100)
		
		for j in keys:
			if(j == keys[keys.size()-1]):
				pokeList.append(validSpawns.get(j))
				break
			if(j >= num):
				pokeList.append(validSpawns.get(j))
				break
			else:
				continue
		
	return pokeList

func spawnPokemon(pokemon):
	while(true):
		var x = randf_range(-1, 1)
		var z = randf_range(-1, 1)

		var pos = to_global(Vector3(x, 0, z))

		if(get_parent().get_parent().groundTileGlobal(pos)):
			get_parent().get_parent().placeForeignObject(load("res://Scenes/WildPokemon/"+pokemon+".tscn"), pos)
			return

func startTimer():
	pass
