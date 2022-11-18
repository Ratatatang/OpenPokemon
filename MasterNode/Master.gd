extends Spatial

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
onready var combatScenePath = "res://Combat/CombatScene.tscn"
onready var menu = $Menu
onready var screenEffectPlayer = $ScreenEffects/AnimationPlayer

# base class for all pokemon. has names, stats and moves

class pokemon:

	var pokedexInfo

	var speciesName
	var displayName

	var gender

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
	var xp = 0
	var neededXP
	var experienceCurve

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

	var healthBar

	var types = []

	func _init(tempName, lv, instPokedex, instMovedex):

		self.speciesName = tempName
		self.displayName = tempName
		self.level = lv

		self.pokedexInfo = instPokedex.get("Pokedex").get(speciesName)
		var moveLvs = pokedexInfo.get("Moves").keys()

		var baseStats = pokedexInfo.get("BaseStats")

		self.experienceCurve = load("res://MasterNode/"+pokedexInfo.get("ExperienceCurve")+".gd").new()
		self.neededXP = experienceCurve.levelFunction(level)

		#print(experienceCurve.levelFunction(level))

		var genderNum = round(rand_range(0, 100))
		var genderRatio = 50
		if(pokedexInfo.keys().has("GenderRatio")):
			genderRatio = pokedexInfo.get("GenderRatio")

		if(genderNum >= genderRatio):
			gender = "Female"
		else:
			gender = "Male"

		#Sets random IV's
		self.hpIV = round(rand_range(0, 31))
		self.atkIV = round(rand_range(0, 31))
		self.defIV = round(rand_range(0, 31))
		self.spAtkIV = round(rand_range(0, 31))
		self.spDefIV = round(rand_range(0, 31))
		self.speedIV = round(rand_range(0, 31))

		#Calculates stats based on base stats & IV's
		self.hp =  round((((2 * baseStats.get("hp") + hpIV + 0) * level)/100) + level + 10)
		self.atk = round((((2 * baseStats.get("atk") + atkIV + 0) * level)/100) + 5)
		self.def = round((((2 * baseStats.get("def") + defIV + 0) * level)/100) + 5)
		self.spAtk = round((((2 * baseStats.get("spAtk") + spAtkIV + 0) * level)/100) + 5)
		self.spDef = round((((2 * baseStats.get("spDef") + spDefIV + 0) * level)/100) + 5)
		self.speed = round((((2 * baseStats.get("speed") + speedIV + 0) * level)/100) + 5)

		self.tempHp = self.hp

		self.types = pokedexInfo.get("Types").duplicate(true)

		get_moves(moveLvs, instMovedex)

	func recalculateStats():
		var baseStats = pokedexInfo.get("BaseStats")

		self.hp =  round((((2 * baseStats.get("hp") + hpIV + 0) * level)/100) + level + 10)
		self.atk = round((((2 * baseStats.get("atk") + atkIV + 0) * level)/100) + 5)
		self.def = round((((2 * baseStats.get("def") + defIV + 0) * level)/100) + 5)
		self.spAtk = round((((2 * baseStats.get("spAtk") + spAtkIV + 0) * level)/100) + 5)
		self.spDef = round((((2 * baseStats.get("spDef") + spDefIV + 0) * level)/100) + 5)
		self.speed = round((((2 * baseStats.get("speed") + speedIV + 0) * level)/100) + 5)

		# this is fucking stupid.
		#(figures out what key values in the moves dictionary need to be appended to availableMoves)

	func get_moves(moveLvs, instMovedex):

		var availableMovesTemp = []

		for i in range(len(moveLvs)):
			if(int(moveLvs[i]) <= self.level):
				var movesToAppend = pokedexInfo.get("Moves").get(moveLvs[i])
				for j in range(len(movesToAppend)):
					if self.availableMoves.find(movesToAppend[j]) <= 0:
						self.availableMoves.append(movesToAppend[j])
						#print("added " + movesToAppend[j])

		availableMovesTemp = availableMoves.duplicate(true)

		# sets the amount of keys to set, and set a key to be a unique move
		# off the tempAvailableMoves list

		var keys = moves.keys()
		
		if len(keys) > len(availableMoves):
			keys.resize(len(availableMoves))

		var move = rand_range(0, len(availableMoves))
		move = round(move)

		for i in len(keys):
			move = rand_range(0, len(availableMovesTemp)-1)
			move = round(move)
			#print(move)
			#print(availableMovesTemp)
			self.moves[keys[i]] = availableMovesTemp[move]
			availableMovesTemp.erase(moves[keys[i]])
			self.moves[keys[i]] = instMovedex.get("Movedex").get(moves[keys[i]])
			self.movePP["move"+str(i+1)+"PP"] = self.moves[keys[i]].get("PP")

	func calculateLevel(addedXP):
		self.xp += addedXP
		while(xp >= neededXP):
			level += 1
			xp -= neededXP
			neededXP = experienceCurve.levelFunction(level)

func _ready():

	#Gets the pokedex
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

	screenEffectPlayer.play("Reset")

	playerPokemonList[0] = pokemon.new("Pidgey", 13, pokedex, movedex)

#Adds a base screen node, and then adds the given screen onto that
func loadScreen(screen):
	currentScene.get_child(0).visible = false
	player.external_set_state("freeze")
	currentScene.add_child(load(screenBase).instance())
	currentScene.get_screen().add_child(load(screen).instance())

#Removes the current base screen & frees the player to move
func exitScreen():
	currentScene.get_child(0).visible = true
	currentScene.get_screen().queue_free()
	player.external_set_state("move")
	player.camera_set()

func _unhandled_input(event):
	if event.is_action_pressed("test"):
		callWildEncounter("Bulbasaur", 5)

func callWildEncounter(species, lv):
	menu.enabled = false
	player.external_set_state("freeze")
	screenEffectPlayer.play("WildCombatStart")
	yield(screenEffectPlayer, "animation_finished")
	currentScene.get_child(0).visible = false
	currentScene.add_child(load(combatScenePath).instance())
	var combatScene = currentScene.get_node("CombatScene")
	combatScene.wild_combat_start(playerPokemonList, pokemon.new(species, lv, pokedex, movedex))
	combatScene.connect("finished_combat", self, "fade_from_combat")
	combatScene.connect("lose_combat", self, "lose_from_combat")
	combatScene.connect("caught_pokemon", self, "capturePokemon")

	screenEffectPlayer.play("FadeToCombat")
	
func fade_from_combat():
	$ScreenEffects/ColorRect.visible = true
	screenEffectPlayer.play("FadeToBlack")
	
	yield(screenEffectPlayer, "animation_finished")
	
	var combatScene = currentScene.get_combatScene()
	combatScene.queue_free()
	currentScene.get_child(0).visible = true
	player = currentScene.get_player()
	player.external_set_state("move")
	player.camera_set()
	menu.enabled = true
	screenEffectPlayer.play("FadeToClear")
	
func capturePokemon(pokemon):
	for i in range(len(playerPokemonList)):
		if(str(playerPokemonList[i]) == ""):
			playerPokemonList[i] = pokemon
			break
			
	fade_from_combat()
