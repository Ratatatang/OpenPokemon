extends Node2D

var pokedex = File.new()
var movedex = File.new()

var ableToBattle = true

var playerPokemonList = [
	"",
	"",
	"",
	"",
	"",
	""
]

onready var currentScene = $CurrentScene
onready var player = currentScene.get_player()
onready var screenBase = "res://OpenWorld/Player/Menu/Menus/Screen.tscn"

# base class for all pokemon. has names, stats and moves

class pokemon:
	
	var pokedexInfo
	
	var speciesName
	var displayName
	
	var baseStats
	
	var hp
	var atk
	var spAtk
	var def
	var spDef
	var speed
	
	var hpIV
	var atkIV
	var spAtkIV
	var defIV
	var spDefIV
	var speedIV
	
	var tempHp
	
	var level
	
	var movePP = {
		"move1PP" : 0,
		"move2PP" : 0,
		"move3PP" : 0,
		"move4PP" : 0,
	}
	
	var moves = {
		"move1": "",
		"move2": "",
		"move3": "",
		"move4": ""
	}
	
	var availableMoves = []
	var availableMovesTemp = []
	
	var healthBar
	
	var types = []
	
	func _init(newName, lv, instPokedex, instMovedex):
		
		self.speciesName = newName
		self.displayName = newName
		self.level = lv
		
		self.pokedexInfo = instPokedex.get("Pokedex").get(speciesName)
		var moveLvs = pokedexInfo.get("Moves").keys()
		
		self.baseStats = pokedexInfo.get("BaseStats")
		
		self.hpIV = round(rand_range(0, 31))
		self.atkIV = round(rand_range(0, 31))
		self.defIV = round(rand_range(0, 31))
		self.spAtkIV = round(rand_range(0, 31))
		self.spDefIV = round(rand_range(0, 31))
		self.speedIV = round(rand_range(0, 31))
		
		self.hp =  round((((2 * baseStats.get("hp") + hpIV + 0) * level)/100) + level + 10)
		self.atk = round((((2 * baseStats.get("atk") + atkIV + 0) * level)/100) + 5)
		self.def = round((((2 * baseStats.get("def") + defIV + 0) * level)/100) + 5)
		self.spAtk = round((((2 * baseStats.get("spAtk") + spAtkIV + 0) * level)/100) + 5)
		self.spDef = round((((2 * baseStats.get("spDef") + spDefIV + 0) * level)/100) + 5)
		self.speed = round((((2 * baseStats.get("speed") + speedIV + 0) * level)/100) + 5)
		
		self.tempHp = self.hp
		
		self.types = pokedexInfo.get("Types").duplicate(true)
		
		get_moves(moveLvs, instMovedex)
		
		instMovedex = null
		availableMovesTemp = []
		
		# this is fucking stupid.
		#(figures out what key values in the moves dictionary need to be appended to availableMoves)
		
		
	func get_moves(moveLvs, instMovedex):
		
		for i in range(len(moveLvs)):
			if(int(moveLvs[i]) <= self.level):
				var movesToAppend = pokedexInfo.get("Moves").get(moveLvs[i])
				for j in range(len(movesToAppend)):
					if self.availableMoves.find(movesToAppend[j]) <= 0:
						self.availableMoves.append(movesToAppend[j])
						print("added " + movesToAppend[j])
		
		self.availableMovesTemp = availableMoves.duplicate(true)
		
		# sets the amount of keys to set, and set a key to be a unique move
		# off the tempAvailableMoves list
		
		var keys = moves.keys()
		
		if len(keys) > len(availableMoves):
			keys.resize(len(availableMoves))
		
		var move = rand_range(0, len(availableMoves))
		move = round(move)
		
		for i in len(keys):
			move = rand_range(0, len(self.availableMovesTemp)-1)
			move = round(move)
			print(move)
			print(availableMovesTemp)
			self.moves[keys[i]] = self.availableMovesTemp[move]
			self.availableMovesTemp.erase(moves[keys[i]])
			self.moves[keys[i]] = instMovedex.get("Movedex").get(moves[keys[i]])
			self.movePP["move"+str(i+1)+"PP"] = self.moves[keys[i]].get("PP")

func _ready():
	var pokedexFile = File.new()
	pokedexFile.open("res://Combat/Pokedex.json", File.READ)
	var pokedexFileData = JSON.parse(pokedexFile.get_as_text())
	pokedexFile.close()
	pokedex = pokedexFileData.result
	
	var movedexFile = File.new()
	movedexFile.open("res://Combat/Movedex.json", File.READ)
	var movedexFileData = JSON.parse(movedexFile.get_as_text())
	movedexFile.close()
	movedex = movedexFileData.result

	playerPokemonList[0] = pokemon.new("Bulbasaur", 4, pokedex, movedex)


func loadScreen(screen):
	player.frozen = true
	player.external_set_state("freeze")
	currentScene.add_child(load(screenBase).instance())
	currentScene.get_screen().add_child(load(screen).instance())

