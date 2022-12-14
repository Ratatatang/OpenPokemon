
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
	
var hpEV = 0
var atkEV = 0
var spAtkEV = 0
var defEV = 0
var spDefEV = 0
var speedEV = 0

var tempHp

var level
var xp = 0
var neededXP
var experienceCurve
	
var participant = false

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
		
	self.xp = calculateXP()
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
	if(level >= 100):
		return
	self.xp += addedXP
	print(addedXP)
	while(xp >= neededXP and level < 100):
		self.level += 1
		print("Gained level. New level: "+str(self.level))
		print("Current XP: "+str(xp)+" next benchmark: "+str(neededXP))
		neededXP = experienceCurve.levelFunction(level)
			
func calculateXP():
	return clamp(experienceCurve.levelFunction(level-1), 0.0, 1640000.0)
			
#func calculateEV(addedEVs):
#	var evTotal = hpEV + atkEV + spAtkEV + defEV + spDefEV + speedEV
#	var keys = addedEVs.keys()
#	for i in range(len(keys)):
#		if(evTotal >= 510):
#			break
#		addedEVs[keys[i]]
