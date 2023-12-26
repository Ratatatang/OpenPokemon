extends Node3D

var player 

@onready var screenNode = $CurrentScene/CurrentScreen
@onready var menu = $Menu
@onready var screenAnim = $ScreenFX/ScreenAnimation

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
			pokemon.new("Bulbasaur", 10),
			pokemon.new("Bulbasaur", 10))

func startCombat(playerPokemon, enemyPokemon):
	$CurrentScene/CurrentScreen/Screen/Combat.startCombat(playerPokemon, enemyPokemon)

func exitScreen():
	screenNode.clearScreens()
