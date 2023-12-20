extends Node2D
class_name battlePlayer

var loadedPokemon
var moves
var volatileEffects = []
var statusEffects = []

var generateBack = false

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
	loadedPokemon = pokemon.new(pokemonName, 10)
	moves = loadedPokemon.moves.duplicate()
	healthBar.max_value = loadedPokemon.hp
	healthBar.value = loadedPokemon.tempHp
	nameLabel.text = pokemonName
	levelLabel.text = "LV " + str(level)
	loadSprite(pokemonName)

func loadSprite(pokemonName):
	var texture
	if(generateBack):
		texture = load("res://Assets/Combat/Pokemon/Back/"+ pokemonName.to_upper() +".png")
	else:
		texture = load("res://Assets/Combat/Pokemon/Front/"+ pokemonName.to_upper() +".png")
	
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
	var tween = create_tween()
	tween.tween_property(healthBar, "value", loadedPokemon.tempHp, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func changeStat(stat, value):
	statsDict[stat] += value
	print(statsDict.get(stat))

func inflictVolatile(value):
	volatileEffects.append(value)

func getName() -> String:
	return loadedPokemon.displayName

func getMoves() -> Array:
	return moves

func getLevel() -> int:
	return loadedPokemon.level

func getAttack() -> int:
	return loadedPokemon.atk

func getDefense() -> int:
	return loadedPokemon.def

func getSpAttack() -> int:
	return loadedPokemon.spAtk

func getSpDefense() -> int:
	return loadedPokemon.spDef

func getTypes() -> Array:
	return loadedPokemon.types
