extends Node

var pokedex: Dictionary
var movedex: Dictionary

func _init():
	var text = FileAccess.open("res://Scripts/GameData/Pokedex.json", FileAccess.READ)
	var json = JSON.new()
	var parse_result = json.parse(text.get_as_text())

	if parse_result != OK:
		print("Error %s reading pokedex file." % parse_result)
		return

	pokedex = json.get_data()


	text = FileAccess.open("res://Scripts/GameData/Movedex.json", FileAccess.READ)
	json = JSON.new()
	parse_result = json.parse(text.get_as_text())

	if parse_result != OK:
		print("Error %s reading movedex file." % parse_result)
		return

	movedex = json.get_data()

func getPokemon(pokeName):
	return pokedex.get("Pokedex").get(pokeName)

func getMove(moveName):
	return movedex.get("Movedex").get(moveName)
