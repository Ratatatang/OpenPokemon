extends Node2D

enum battleType{
	WILD_SINGLE
	WILD_DOUBLE
	WILD_MULTI
}

var battle_Type = battleType.WILD_SINGLE

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

var healthyBar = "res://Combat/Health/HealthyHealthProgress.png"
var cautionBar = "res://Combat/Health/CautionHealthProgress.png"
var dangerBar = "res://Combat/Health/DangerHealthProgress.png"

var typeEffect

onready var ActionSelect = $ActionSelect
onready var MoveSelect = $MoveSelect
onready var Dialoge = $Dialouge/RichTextLabel

onready var buttons = {
	"Move1" : $MoveSelect/Move1,
	"Move2" : $MoveSelect/Move2,
	"Move3" : $MoveSelect/Move3,
	"Move4" : $MoveSelect/Move4
}

var outcomeQueue = []

var enemyMoves
var playerMoves

signal finished_combat
signal lose_combat
signal escape
signal caught_pokemon
signal xp

var combatPokedex
var combatMovedex

var playerActive1
var enemyActive1

var playerList = ["", "", "", "", "", ""]
var enemyList = ["", "", "", "", "", ""]

var trainerBattle = false

# class for a selected move, used by the text queue and
# damage calculations

class selectedMove:
	
	var speed
	var attack
	var attacker
	var victim
	var priority
	
	func _init(mve, atkr, victm):
		self.attack = mve
		self.attacker = atkr
		self.victim = victm
		self.priority = self.attack.Priority
		self.speed = self.attacker.pokemon.speed
	
	func get_type():
		return "selectedMove"
			
		
class selectedAction:
	var move
	var speed
	var priority
	
	func _init(move, priority = 0):
		self.move = move
		self.speed = 0
		self.priority = priority
	
	func get_type():
		return "selectedAction"
		
class flavorText:
	var move
	var speed
	var priority
	
	func _init(move):
		self.move = move
		self.speed = 0
		self.priority = 0
	
	func get_type():
		return "flavorText"
		
# Helper class that stores data for the sorting loop
		
class unsortedMove:
	
	var type
	var move
	var speed
	var priority
	
	func _init(move):
		self.move = move
		self.speed = move.speed
		self.priority = move.priority
		
# class for a active battling pokemon
		
class battlingMon:
	
	var displayName
	
	var healthBar
	var sprite
	
	var pokemon
	
	var tempAtk
	var tempSpAtk
	var tempDef
	var tempSpDef
	var tempSpeed
	var tempAcucy
	var tempEvsn
	
	func _init(mon, slot):
		mon.participant = true
		self.pokemon = mon
		self.healthBar = slot.get_node("healthbar")
		self.sprite = slot.get_node("sprite")
		self.displayName = self.pokemon.displayName
		healthBar.get_node("name").text = displayName
		healthBar.get_node("level").text = str(mon.level)
		setStats()
	
	func changeStat(stat, value):
		if(stat == "Attack"):
			self.tempAtk += value
		elif(stat == "Special Attack"):
			self.tempSpAtk += value
		elif(stat == "Defence"):
			self.tempDef += value
		elif(stat == "Special Defence"):
			self.tempSpDef += value
		elif(stat == "Speed"):
			self.tempSpeed += value
		elif(stat == "Evasion"):
			self.tempEvsn += value
		elif(stat == "Accuracy"):
			self.tempAcucy += value
	
	func setStats():
		self.tempAtk = 0
		self.tempDef = 0
		self.tempSpAtk = 0
		self.tempSpDef = 0
		self.tempSpeed = 0
		self.tempAcucy = 0
		self.tempEvsn = 0
	
# for externally setting the pokemon in use
"""func set_mons(team, index, pokemon):
	if(team == "enemy"):
		enemyList[index] = pokemon
	if(team == "player"):
		playerList[index] = pokemon
	if(team == "playerList"):
		playerList = pokemon
	if(team == "enemy1"):
		enemyActive1 = battlingMon.new(pokemon, $EnemyPosition/TextureProgress)"""
		
# starts wild combat by setting the correct sprites and name for the 
# what will ____ do message

func wild_combat_start(playerTeam, enemyPokemon):
	playerList = playerTeam
	playerActive1 = battlingMon.new(playerList[0], $PlayerPosition)
	
	playerActive1.sprite.texture = load("res://Combat/Sprites/Back/"+playerActive1.pokemon.speciesName.to_upper()+".png")
#	if(playerActive1.pokemon.dimorphism):
#		playerActive1.sprite.texture = load("res://Combat/Sprites/Back/"+playerActive1.pokemon.speciesName.to_upper()+"_female.png")
		
	playerMoves = playerActive1.pokemon.moves
	
	
	enemyActive1 = battlingMon.new(enemyPokemon, $EnemyPosition)
	enemyActive1.sprite.texture = load("res://Combat/Sprites/Front/"+enemyActive1.pokemon.speciesName.to_upper()+".png")
#	if(enemyActive1.pokemon.dimorphism):
#		enemyActive1.sprite.texture = load("res://Combat/Sprites/Front/"+enemyActive1.pokemon.speciesName.to_upper()+"_female.png")
	
	enemyMoves = enemyActive1.pokemon.moves.values()
	enemyActive1.displayName = "Enemy " + enemyActive1.displayName
	while str(enemyMoves[len(enemyMoves)-1]) == "":
		enemyMoves.resize(len(enemyMoves)-1)
	
	var percentHealth = playerActive1.pokemon.tempHp/playerActive1.pokemon.hp
	playerActive1.healthBar.value = round(playerActive1.healthBar.value * percentHealth)
	
	update_healthbar_color(percentHealth, playerActive1.healthBar)
	
	
	$ActionSelect/RichTextLabel.text = "What will " + playerActive1.displayName + " do?"
	buttonMoves()
	set_control("Action")
	
# just makes sure that certain values are correct

func _ready():
	
	combatMovedex = get_node("/root/Master").movedex
	combatPokedex = get_node("/root/Master").pokedex
	
	var typeFile = File.new()
	typeFile.open("res://Combat/TypeMatchups.json", File.READ)
	var typeEffectFileData = JSON.parse(typeFile.get_as_text())
	typeFile.close()
	typeEffect = typeEffectFileData.result
		
	ActionSelect.get_child(0).disabled = false
	
# _process just for managing inputs. don't try to match state here.

func _process(delta):
	randomize()
	if Input.is_action_pressed("spin"):
		enemyActive1.sprite.rotation_degrees += 999999999999999999
		playerActive1.sprite.rotation_degrees += 999999999999999999
	if Input.is_action_just_pressed("escape") and $ActionSelect.visible == false and Dialoge.visible == false:
		set_control("Action")
	elif(Input.is_action_just_pressed("escape") and Dialoge.visible == true):
		emit_signal("escape")
		
# just sets what control should be visable

func set_control(control):
	if control == "ActionSelect" or control == "Action":
		ActionSelect.visible = true
		MoveSelect.visible = false
		Dialoge.visible = false
	if control == "MoveSelect" or control == "Move":
		ActionSelect.visible = false
		MoveSelect.visible = true
		Dialoge.visible = false
	if control == "Dialouge":
		ActionSelect.visible = false
		MoveSelect.visible = false
		Dialoge.visible = true
		
# sets the buttons to be the correct color and move

func buttonMoves():
	var numMoves = playerMoves.values()
	while numMoves.find("") >= 0:
		numMoves.erase("")
	numMoves = len(numMoves)

	for i in numMoves:
		buttons["Move"+str(i+1)].visible = true
		var buttonMove = playerMoves["move"+str(i+1)]
		var buttonType = buttonMove.get("Type")
		buttonType.capitalize()
		buttons["Move"+str(i+1)].texture_normal = load("res://Combat/Buttons/"+buttonType+"_Button.png")
		buttons["Move"+str(i+1)].find_node("Label").text = buttonMove.get("DisplayName")

func DecideMon():
	pass

func DecideMove():
	set_control("Action")
	buttonMoves()
	
var moves 
	
# Main loop function for combat decisions
# Takes the move selected by the player, and figures out what the enemy will do,
# Then it loops through a list constructed of all the actions that need to take place
# Needs to be rewritten 
	
func Outcome(playerSelectedAction):
	set_control("Dialouge")
	
	# replace with some actual AI at some point. 
	# notes for AI: enemyMove is a list of dictionary entries for moves, no blanks

	var enemySelectedAction = rand_range(0, len(enemyMoves)-1)
	enemySelectedAction = round(enemySelectedAction)
	enemySelectedAction = enemyMoves[enemySelectedAction]
	enemySelectedAction = selectedMove.new(enemySelectedAction, enemyActive1, playerActive1)
	
	moves = [playerSelectedAction, enemySelectedAction]
	
	print("Unsorted: "+str(moves))
	
	speedCalculator(moves)
	
	print("Sorted: "+str(moves))
	
	# replace appends with a speed calculator to determine turn order
	
	var finishedTextLoop = false
	
	while finishedTextLoop == false:
		
		print("")
		
		var category
		
		
		
		if(moves[0].get_type() == "flavorText"):
			Dialoge.text = moves[0].move
		else:
			var moveHit = doesMoveHit(moves[0])
			moveText(moveHit, moves[0])
			category = moves[0].attack.Category
			
			if(category == "Physical" or category == "Special"):
				var effective = effectiveness(moves[0].attack.Type, moves[0].victim.pokemon.pokedexInfo.Types)
				moveAttack(moves[0], effective)
				print("Attacking Move")
			elif(category == "Status"):
				change_stats(moves[0])
		
		yield(self, "escape")
		
		if(moves[0].get_type() == "captured"):
			emit_signal("caught_pokemon", enemyActive1.pokemon)
			moves.insert(0, selectedAction.new(" "))
		
		#Ends the loop, but if the player/enemy's health are 0 ends combat
		if(1 == len(moves)):
			if(playerActive1.pokemon.tempHp == 0):
				combatEnd(enemyActive1)
				moves.insert(0, " ")
			elif(enemyActive1.pokemon.tempHp == 0):
				combatEnd(playerActive1)
				moves.insert(0, " ")
			else:
				finishedTextLoop = true
				break
		else:	
			if(typeof(moves[1]) != TYPE_STRING):
				if(playerActive1.pokemon.tempHp == 0):
					combatEnd(enemyActive1)
					moves.insert(1, selectedAction.new(" "))
				elif(enemyActive1.pokemon.tempHp == 0):
					combatEnd(playerActive1)
					moves.insert(1, selectedAction.new(" "))
			
			moves.remove(0)
		
	set_control("Action")
		
# function for if the move will hit
# does not account for accuracy / evasion changes yet

func doesMoveHit(move):
	if(move.attack.Accuracy < 101):
		var Accuracy = move.attack.Accuracy
		var hit = rand_range(1, 100)
		hit = round(hit)
		if hit <= Accuracy:
			return true
		else: 
			return false
	else:
		return true
		
# calcuates move damage
		
func moveAttack(move, effectiveness):
	var attack = move.attack
	var straightDamage = float(move.attack.Power)
	var attackerMod
	var victimMod
	var attackerLv = float(move.attacker.pokemon.level)
	
	#Figures the category that should be used, special or physical
	if(attack.Category == "Physical"):
		attackerMod = float(move.attacker.pokemon.atk * (statChanges.get(str(move.attacker.tempAtk))))
		victimMod = float(move.victim.pokemon.def * (statChanges.get(str(move.victim.tempDef))))
	elif(attack.Category == "Special"):
		attackerMod = float(move.attacker.pokemon.spAtk * (statChanges.get(str(move.attacker.tempSpAtk))))
		victimMod = float(move.victim.pokemon.spDef * (statChanges.get(str(move.victim.tempSpDef))))
	
	var random = round(rand_range(85.0, 100.0))
	random = float("0." + str(random))
	
	print("percentage of damage: " + str(random))
	
	var STAB = 1.0
	
	if(move.attacker.pokemon.types.find(move.attack.Type) >= 0):
		STAB += 0.5
	
	# Ew
	var damage = 2.0 * attackerLv
	damage /= 5.0
	damage += 2.0
	damage *= straightDamage
	damage *= (attackerMod / victimMod)
	damage /= 50.0
	damage += 2.0
	damage *= random
	damage *= STAB
	damage *= effectiveness
	
	#Ignore that ridiculous number lmao
	damage = clamp(round(damage), 1, 99999999999999)
	
	print("move damage: " + str(damage))
	print("prev hp: " + str(move.victim.pokemon.tempHp))
	
	move.victim.pokemon.tempHp -= damage
	
	if(move.victim.pokemon.tempHp < 0):
		move.victim.pokemon.tempHp = 0
	
	print("new hp: " + str(move.victim.pokemon.tempHp))
	
	update_healthbar(move, damage)
	
# speed calculator/sorter

func speedCalculator(unsortedMoves):
	var moves = unsortedMoves.duplicate(true)
	var sorted = []
	var messages = ["captured", "notCaptured"]
	
	# It has to package them so they dont crash when you try to read speed on non moves
	for i in range(len(moves)):
		moves[i] = unsortedMove.new(moves[i])
	
	var priorities = {
		"7": [],
		"6": [],
		"5": [],
		"4": [],
		"3": [],
		"2": [],
		"1": [],
		"0": [],
		"-1": [],
		"-2": [],
		"-3": [],
		"-4": [],
		"-5": [],
		"-6": [],
		"-7": []
	}
	
	if(moves.find("captured") >= 0):
		priorities["7"].append(moves.pop_at(moves.find("captured")))
	elif(moves.find("notCaptured") >= 0):
		priorities["7"].append(moves.pop_at(moves.find("notCaptured")))
	
	for i in range(len(moves)):
		var priority = str(moves[i].priority)
		priorities[priority].append(moves[i])
	
	
	var keys = priorities.keys()
	
	for i in range(len(keys)):
		var current = priorities[keys[i]]
		if(len(current) > 0):
			if(len(current) > 1):
				
				# Bubble sorts if the priortiy list has more then 1 act in it
				
				for k in range(len(current)):
					var alreadySorted = true
					
					# This is disgusting fucking 7 nests in ewwwwwwwwwww
					# I hate this lmao
					for l in range(len(current) - k - 1):
						if current[l].speed > current[l + 1].speed:
							
							var currValue = current[l]
							var swapValue = current[l + 1]
							
							current[l] = swapValue
							current[l+1] = currValue
							
							alreadySorted = false
							
					if(alreadySorted == true):
						break
			# Puts them allllll into the sorted list
			for j in range(len(current)):
				sorted.append(current[j].move)
		else:
			continue
			
	return sorted
		
# function for the move text
func moveText(miss, move):
	if miss == false:
		Dialoge.text = move.attacker.displayName + " used " + move.attack.get("DisplayName") + " on " + move.victim.displayName + "!"
	else:
		Dialoge.text = move.attacker.displayName + " missed."
		
# updates the healthbar values by getting what percent health
# the pokemon has and setting the bar to the same percent
		
func update_healthbar(move, damage, duration = 0.45):
	
	var healthBar = move.victim.healthBar
	var health = move.victim.pokemon.tempHp
	var maxHealth = move.victim.pokemon.hp
	
	var percentHealth = health/maxHealth

	var barPercent = round(1000 * percentHealth)
	
	if(barPercent <= 2 and percentHealth > 0):
		barPercent = 2
	
	print("Bar Percent: " + str(percentHealth))
	
	$HealthTween.interpolate_property(healthBar, "value", healthBar.value, barPercent, duration, Tween.TRANS_LINEAR)
	$HealthTween.start()
	
	print("healthbar value: " + str(barPercent))
		
	update_healthbar_color(percentHealth, healthBar)
		
#Updates the displayed healthbar to the correct color

func update_healthbar_color(percent, healthBar):
		if(percent <= 0.2):
			healthBar.texture_progress = load(dangerBar)
		elif(percent <= 0.4):
			healthBar.texture_progress = load(cautionBar)
		else:
			healthBar.texture_progress = load(healthyBar)
		
# calculates move effectivness
		
func effectiveness(atkType, defTypes):
	
	var defType1 = defTypes[0]
	var defType2 = ""
	
	if(len(defTypes) > 1):
		defType2 = defTypes[1]
	
	var keys = typeEffect[atkType].keys()
	var typeEffective
	
	if(keys.find(defType1) >= 0):
		typeEffective = typeEffect[atkType][defType1]
	else:
		typeEffective = 1
	
	if(defType2 != ""):
		if(keys.find(defType2) >= 0):
			typeEffective = typeEffective * typeEffect[atkType][defType2]
	else:
		typeEffective += 0
	
	if(typeEffective > 1):
		moves.insert(1, flavorText.new("It Was Super Effective!"))
	elif(typeEffective < 1 and typeEffective > 0):
		moves.insert(1, flavorText.new("Not Very Effective..."))
	
	return typeEffective
	
# Changes a stat for the appropriate victim
	
func change_stats(move):
	var changes = move.attack.StatChanges.keys()
	
	for i in len(changes):
		var hit = rand_range(0, 100)
		hit = round(hit)
		var accuracy = int(changes[i])
		if(hit <= accuracy):
			var target = move.attack.StatChanges.get(changes[i]).get("Target")
			if target == "Victim":
				target = move.victim
			elif target == "Self":
				target = move.attacker
			changeStat(move.attack.StatChanges.get(changes[i]), target)

# change stat function

func changeStat(stat, target):
	var keys = stat.keys()
	keys.erase("Target")
	for i in len(keys):
		var value = stat.get(keys[i])
		var changedStat = keys[i]
		target.changeStat(changedStat, value)
		
# ends combat
		
func combatEnd(victor):
	if(victor == playerActive1):
		emit_signal("xp", enemyActive1.pokemon)
		emit_signal("finished_combat")
	if(victor == enemyActive1):
		emit_signal("lose_combat")
		
# captures a wild pokemon

func capturePokemon(targetPokemon):
	var percent = round(rand_range(0, 100))
	var captureRate = (30 - targetPokemon.pokemon.level) / 10
	if(percent >= captureRate):
		Outcome(selectedAction.new("captured", 7))
	else:
		Outcome(selectedAction.new("notCaptured", 7))
		
# on button pressed functions

func _on_Bag_pressed():
	capturePokemon(enemyActive1)
	
func _on_Run_pressed():
	emit_signal("finished_combat")
	
func _on_Fight_pressed():
	set_control("Move")

func _on_Pokemon_pressed():
	pass

# functions for hovering over the attack buttons

onready var NameDisplay = MoveSelect.get_node("NameDisplay")
onready var PPDisplay = MoveSelect.get_node("PPDisplay")

func _on_Move1_mouse_entered():
	PPDisplay.text = "PP : " + str(playerActive1.pokemon.movePP.get("move1PP")) + "/" + str(playerMoves["move1"].get("PP"))
	
	
func _on_Move2_mouse_entered():
	PPDisplay.text = "PP : " + str(playerActive1.pokemon.movePP.get("move2PP")) + "/"+ str(playerMoves["move2"].get("PP"))


func _on_Move3_mouse_entered():
	PPDisplay.text = "PP : " + str(playerActive1.pokemon.movePP.get("move3PP")) + "/"+ str(playerMoves["move3"].get("PP"))


func _on_Move4_mouse_entered():
	PPDisplay.text = "PP : " + str(playerActive1.pokemon.movePP.get("move4PP")) + "/"+ str(playerMoves["move4"].get("PP"))

# move buttons pressed functions

func _on_Move1_pressed():
	var playerSelectedMove = selectedMove.new(playerMoves["move1"], playerActive1, enemyActive1)
	Outcome(playerSelectedMove)

func _on_Move2_pressed():
	var playerSelectedMove = selectedMove.new(playerMoves["move2"], playerActive1, enemyActive1)
	Outcome(playerSelectedMove)

func _on_Move3_pressed():
	var playerSelectedMove = selectedMove.new(playerMoves["move3"], playerActive1, enemyActive1)
	Outcome(playerSelectedMove)
	
func _on_Move4_pressed():
	var playerSelectedMove = selectedMove.new(playerMoves["move4"], playerActive1, enemyActive1)
	Outcome(playerSelectedMove)
	
