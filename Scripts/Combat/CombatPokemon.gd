extends Node2D
class_name battlePlayer

var loadedPokemon
var moves
var volatileEffects = []
var statusEffect

var generateBack = false
var enemy = false
var skipMove = false
var opponent
var tween

var sleepCounter = 0
@onready var sprite = $Sprite2D
@onready var healthBar = $Healthbar
@onready var nameLabel = $Healthbar/Name
@onready var levelLabel = $Healthbar/Level
@onready var statusIcon = $Healthbar/IconStatuses

var UI

var statsDict = {
	"Attack" : 0,
	"Special Attack" : 0,
	"Defense" : 0,
	"Special Defense" : 0,
	"Speed" :  0,
	"Accuracy" : 0,
	"Evasion" : 0,
	"Crit Ratio": 0
}

func loadPokemon(pokemonInst):
	loadedPokemon = pokemonInst
	loadedPokemon.participant = true
	moves = loadedPokemon.moves.duplicate()
	healthBar.value = (loadedPokemon.tempHp / loadedPokemon.hp) * 1000
	nameLabel.text = loadedPokemon.displayName
	levelLabel.text = "LV " + str(loadedPokemon.level)
	
	if(loadedPokemon.statusEffect != null):
		statusEffect = loadedPokemon.statusEffect
		statusIcon.frame = statusEffect.iconFrame
	
	volatileEffects = []
	sleepCounter = 0
	skipMove = false
	statsDict = {"Attack" : 0, "Special Attack" : 0, "Defense" : 0, "Special Defense" : 0, "Speed" :  0, "Accuracy" : 0, "Evasion" : 0, "Crit Ratio": 0}
	
	loadSprite(loadedPokemon.speciesName)

func loadSprite(pokemonName):
	var texture
	var gen = "Front"
	if(generateBack):
		gen = "Back"
		sprite.position = Vector2(-226, -388)
	else:
		sprite.position = Vector2(-207, -317)
	texture = "res://Assets/Combat/Pokemon/%s/%s.png" % [gen, pokemonName.to_upper()]
	
	if(FileAccess.file_exists(texture)):
		texture = load(texture)
	else:
		print("%s sprite doesn't exist! Defaulting to 000 sprite." % pokemonName.to_upper())
		texture = load("res://Assets/Combat/Pokemon/Front/000.png")
	
	sprite.texture = texture
	
	var image = texture.get_image().get_used_rect()
	var rect = Rect2(0, 0,
		(image.position.x + image.size.x),
		(image.position.y + image.size.y)
	)
	sprite.region_rect = rect
	sprite.position.y += (96-rect.size.y)*4
	
	if(!generateBack):
		healthBar.position.y += (96-rect.size.y)*4

func reduceHP(amount):
	loadedPokemon.tempHp -= floor(amount)
	
	if(loadedPokemon.tempHp < 0):
		amount + loadedPokemon.tempHp
		loadedPokemon.tempHp = 0
		
	var percentHP = (loadedPokemon.tempHp / loadedPokemon.hp) * 1000
	
	var tween = create_tween()
	tween.tween_property(healthBar, "value", percentHP, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	return amount
	
func reducePercentHP(percent):
	return reduceHP(loadedPokemon.hp / percent)

func heal(amount):
	loadedPokemon.tempHp += floor(amount)
	
	if(loadedPokemon.tempHp > loadedPokemon.hp):
		amount - loadedPokemon.tempHp
		loadedPokemon.tempHp = loadedPokemon.hp
		
	var percentHP = (loadedPokemon.tempHp / loadedPokemon.hp) * 1000
		
	var tween = create_tween()
	tween.tween_property(healthBar, "value", percentHP, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	return amount

func changeStat(stat, value : int):
	statsDict[stat] += value
	

func inflictVolatile(value):
	var effect = load("res://Scripts/Combat/StatusConditions/%s.gd" % [value]).new()
	
	for effects in volatileEffects:
		if(effects.getStatusName() == effect.getStatusName()):
			UI.setDialog("{Pokemon} is already {Status}!".format(
			{"Pokemon": getName(), "Status": effects.getStatusName()}))
			return true
		
	volatileEffects.append(effect)
	
	if(effect.hasStartMessage):
		UI.setDialog(
			effect.startMessage.format({
				"Pokemon":getName()}))
		return true
	
	return false

func inflictStatus(value : String):
	if(statusEffect == null):
		statusEffect = load("res://Scripts/Combat/StatusConditions/%s.gd" % [value]).new()
		loadedPokemon.statusEffect = statusEffect
		
		statusIcon.frame = statusEffect.iconFrame
		
		if(statusEffect.hasStartMessage):
			UI.setDialog(
				statusEffect.startMessage.format({
					"Pokemon":getName()}))
			return true
			
	elif(statusEffect != null):
		UI.setDialog("{Pokemon} is already {Status}!".format(
			{"Pokemon": getName(), "Status": statusEffect.statusName}))
		return true
	
	return false

func clearStatus(status):
	if(status.statusName == statusEffect.statusName):
		statusEffect = null
		loadedPokemon.statusEffect = null
		statusIcon.frame = 0
	
	for effects in volatileEffects:
		if(effects.statusName == status.statusName):
			volatileEffects.erase(effects)

func deathTween():
	var rect = sprite.region_rect
	
	tween = create_tween()
	tween.tween_property(sprite, "region_rect", Rect2(0, -96, rect.size.x, rect.size.y), 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

		
func getName() -> String:
	if(enemy):
		return "Enemy " + loadedPokemon.displayName
	else:
		return loadedPokemon.displayName

func getStatuses():
	if(statusEffect != null):
		return volatileEffects + [statusEffect]
	return volatileEffects

func getMoves() -> Array:
	return moves

func getLevel() -> int:
	return loadedPokemon.level

func getHP():
	return loadedPokemon.tempHp

func getAttack() -> int:
	return clamp(loadedPokemon.atk * 
	MasterInfo.statChanges.get(str(statsDict.get("Attack"))), 1, 999)

func getDefense() -> int:
	return clamp(loadedPokemon.def * 
	MasterInfo.statChanges.get(str(statsDict.get("Defense"))), 1, 999)

func getSpAttack() -> int:
	return clamp(loadedPokemon.spAtk * 
	MasterInfo.statChanges.get(str(statsDict.get("Special Attack"))), 1, 999)

func getSpDefense() -> int:
	return clamp(loadedPokemon.spDef * 
	MasterInfo.statChanges.get(str(statsDict.get("Special Defense"))), 1, 999)

func getCritRatio() -> int:
	return statsDict.get("Crit Ratio")

func getAccuracy():
	return statsDict.get("Accuracy")

func getEvasion():
	return statsDict.get("Evasion")

func getSpeed() -> int:
	return clamp(loadedPokemon.speed * 
	MasterInfo.statChanges.get(str(statsDict.get("Speed"))), 1, 999)

func getTypes() -> Array:
	return loadedPokemon.types
