extends Node2D

var movedex
var pokedex

onready var timer = $Timer
onready var walkingMon = $Position2D/KinematicBody2D

var keys 

func _ready():
	var pokedexFile = File.new()
	pokedexFile.open("res://Combat/Pokedex.json", File.READ)
	var pokedexFileData = JSON.parse(pokedexFile.get_as_text())
	pokedexFile.close()
	pokedex = pokedexFileData.result

	#Gets the movedex
	var movedexFile = File.new()
	movedexFile.open("res://Combat/Movedex.json", File.READ)
	var movedexFileData = JSON.parse(movedexFile.get_as_text())
	movedexFile.close()
	movedex = movedexFileData.result
	
	keys = pokedex.get("Pokedex").keys()
	
	_on_Timer_timeout()

func _on_Timer_timeout():
	walkingMon.position = Vector2(0, 0)
	
	var item = keys[round(rand_range(0, keys.size()-1))]
	item = pokedex.get("Pokedex").get(item).get("Name").to_upper()
	
	
	walkingMon.setSprite("res://OpenWorld/WildPokemon/Sprites/Followers/"+ item +".png")
