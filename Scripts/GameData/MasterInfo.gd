extends Node

var pokedex: Dictionary
var movedex: Dictionary

var typeMatchups = {
	"Normal" : {
		"Rock": 0.5,
		"Ghost": 0,
		"Steel": 0.5
	},
	"Fire" : {
		"Fire": 0.5,
		"Water": 0.5,
		"Grass": 2,
		"Ice": 2,
		"Bug": 2,
		"Rock": 0.5,
		"Dragon": 0.5,
		"Steel": 2
	},
	"Water": {
		"Fire": 2,
		"Water": 0.5,
		"Grass": 0.5,
		"Ground": 2,
		"Rock": 2,
		"Dragon": 0.5
	},
	"Grass": {
		"Fire": 0.5,
		"Water": 2,
		"Grass": 0.5,
		"Poison": 0.5,
		"Ground": 2,
		"Flying": 0.5,
		"Rock": 2,
		"Dragon": 0.5,
		"Steel": 0.5
	},
	"Bug": {
		"Fire": 0.5,
		"Grass": 2,
		"Fighting": 0.5,
		"Poison": 0.5,
		"Flying": 0.5,
		"Psychic": 2,
		"Ghost": 0.5,
		"Dark": 2,
		"Steel": 0.5,
		"Fairy": 0.5
	},
	"Flying": {
		"Grass": 2,
		"Electric": 0.5,
		"Fighting": 2,
		"Bug": 2,
		"Rock": 0.5,
		"Steel": 0.5
	},
	"Rock" : {
		"Flying": 2,
		"Fire": 2,
		"Ice": 2,
		"Ground": 2,
		"Bug": 2,
		"Steel": 0.5,
		"Fighting": 0.5,
		"Poison": 0.5
	},
	"Ground": {
		"Fire": 2,
		"Electric": 2,
		"Grass": 0.5,
		"Poison": 2,
		"Flying": 0,
		"Bug": 0.5,
		"Rock": 2,
		"Steel": 2
	},
	"Dark": {
		"Psychic": 2,
		"Fighting": 0.5,
		"Ghost": 2,
		"Dark": 0.5,
		"Steel": 0.5,
		"Fairy": 0.5
	},
	"Poison": {
		"Grass": 2,
		"Poison": 0.5,
		"Ground": 0.5,
		"Rock": 0.5,
		"Ghost": 0.5,
		"Steel": 0,
		"Fairy": 2
	},
	"Electric": {
		"Water": 2,
		"Electric": 0.5,
		"Grass": 0.5,
		"Ground": 0,
		"Flying": 2,
		"Dragon": 0.5
	},
	"Fighting": {
		"Dark": 2,
		"Ice": 2,
		"Rock": 2,
		"Poison": 0.5,
		"Flying": 0.5,
		"Psychic": 0.5,
		"Bug": 0.5,
		"Ghost": 0,
		"Steel": 2,
		"Fairy": 0.5
	},
	"Psychic": {
		"Dark": 0,
		"Fighting": 2,
		"Poison": 2,
		"Psychic": 0.5,
		"Steel": 0.5
	},
	"Ice": {
		"Dragon": 2,
		"Grass": 2,
		"Fire": 0.5,
		"Water": 0.5,
		"Ice": 0.5,
		"Ground": 2,
		"Flying": 2,
		"Steel": 0.5
	},
	"Ghost": {
		"Ghost": 2,
		"Psychic": 2,
		"Normal": 0,
		"Dark": 0.5,
		"Steel": 0.5
	},
	"Dragon": {
		"Dragon": 2,
		"Steel": 0.5,
		"Fairy": 0
	},
	"Steel": {
		"Fire": 0.5,
		"Water": 0.5,
		"Grass": 0.5,
		"Ice": 2,
		"Rock": 2,
		"Steel": 0.5,
		"Fairy": 2
	},
	"Fairy": {
		"Dragon": 2,
		"Fire": 0.5,
		"Fighting": 2,
		"Poison": 0.5,
		"Dark": 2,
		"Steel": 0.5
	}
}

var statChanges = {
	"-6": 0.25,
	"-5": 0.28,
	"-4": 0.33,
	"-3": 0.4,
	"-2": 0.5,
	"-1": 0.66,
	"0": 1,
	"1": 1.5,
	"2": 2,
	"3": 2.5,
	"4": 3,
	"5": 3.5,
	"6": 4
}

var accuracyChanges = {
	"-6": 0.33333333333,
	"-5": 0.375,
	"-4": 0.42857142857,
	"-3": 0.5,
	"-2": 0.6,
	"-1": 0.75,
	"0": 1,
	"1": 1.33333333333,
	"2": 1.66666666667,
	"3": 2,
	"4": 2.33333333333,
	"5": 2.66666666667,
	"6": 3
}

var changesDialog = {
	"-3": "%s's %s severely fell!",
	"-2": "%s's %s harshly fell!",
	"-1": "%s's %s fell!",
	"1": "%s's %s rose!",
	"2": "%s's %s rose sharply!",
	"3": "%s's %s drastically!"
}

var critRatio = {
	"1": 1/24,
	"2": 1/8,
	"3": 1/2,
	"4": 1/1
}

var effectiveDialog = {
	"2": "It's Super Effective!",
	"0.5": "It's Not Very Effective..."
}

var worldGenNode
var worldMapNode
var worldMap

var playerPosition = Vector2.ZERO

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

func setPlayer(pos):
	pos = worldMapNode.to_local(pos)
	playerPosition = worldMapNode.local_to_map(pos)

func getPokemon(pokeName):
	return pokedex.get("Pokedex").get(pokeName)

func getAllPokemon():
	return pokedex.get("Pokedex").keys()

func getMove(moveName):
	return movedex.get("Movedex").get(moveName)
