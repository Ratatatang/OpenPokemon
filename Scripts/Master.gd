extends Node3D

var player 
var playerPokemon = []

@onready var screenNode = $CurrentScene/CurrentScreen
@onready var menu = $Menu
@onready var screenAnim = $ScreenFX/ScreenAnimation

func _ready():
	playerPokemon.append(pokemon.new("Bulbasaur", 10))
	screenAnim.play("loading")

#Updates FPS counter every process
func _process(delta):
	$FPS.text = str(Engine.get_frames_per_second())

func _input(event):
	if(event.is_action_pressed("testCombat")):
		screenAnim.play("StartCombat")

func loadScreen(path):
	screenNode.add_child(load(path).instantiate())

func fadeToCombat():
	loadScreen("res://Scenes/Combat/combat_scene.tscn")
	startCombat(
			playerPokemon[0],
			pokemon.new("Bulbasaur", 10))

func startCombat(playerPokemon, enemyPokemon):
	$CurrentScene/CurrentScreen/Combat.startCombat(playerPokemon, enemyPokemon)

func exitScreen():
	screenNode.clearScreens()

func checkLoad():
	$Timer.start()
	await $Timer.timeout
	$Timer.queue_free()
	screenAnim.play("fadeFromLoading")
