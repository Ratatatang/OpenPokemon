extends Node2D
class_name battlePlayer

var loadedPokemon
var moves
var volatileEffects = []
var statusEffect

var generateBack = false
var enemy = false

@onready var sprite = $Sprite2D
@onready var healthBar = $Healthbar
@onready var nameLabel = $Healthbar/Name
@onready var levelLabel = $Healthbar/Level

var statsDict = {
	"Attack" : 0,
	"Special Attack" : 0,
	"Defense" : 0,
	"Special Defense" : 0,
	"Speed" :  0,
	"Accuracy" : 0,
	"Evasion" : 0
}

func loadPokemon(pokemonName, level = 10):
	loadedPokemon = pokemon.new(pokemonName, level)
	moves = loadedPokemon.moves.duplicate()
	healthBar.max_value = loadedPokemon.hp
	healthBar.value = loadedPokemon.tempHp
	nameLabel.text = pokemonName
	levelLabel.text = "LV " + str(level)
	loadSprite(pokemonName)

func loadSprite(pokemonName):
	var texture
	var gen = "Front"
	if(generateBack):
		gen = "Back"
	texture = load("res://Assets/Combat/Pokemon/%s/%s.png" % [gen, pokemonName.to_upper()])
	
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
	loadedPokemon.tempHp -= amount
	
	if(loadedPokemon.tempHp < 0):
		loadedPokemon.tempHp = 0
		
	var tween = create_tween()
	tween.tween_property(healthBar, "value", loadedPokemon.tempHp, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func reducePercentHP(percent):
	reduceHP(loadedPokemon.hp / percent)

func changeStat(stat, value : int):
	statsDict[stat] += value

func inflictVolatile(value):
	volatileEffects.append(value)

func inflictStatus(value : String):
	if(statusEffect == null):
		statusEffect = load("res://Scripts/Combat/StatusConditions/%s.gd" % [value]).new()
		
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


func getAttack() -> int:
	return clamp(loadedPokemon.atk, 1, 999)

func getDefense() -> int:
	return clamp(loadedPokemon.def, 1, 999)

func getSpAttack() -> int:
	return clamp(loadedPokemon.spAtk, 1, 999)

func getSpDefense() -> int:
	return clamp(loadedPokemon.spDef, 1, 999)

func getSpeed() -> int:
	return clamp(loadedPokemon.speed, 1, 999)

func getTypes() -> Array:
	return loadedPokemon.types
