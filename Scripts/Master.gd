extends Node3D

var player 
var playerPokemon = []

@onready var screenNode = $CurrentScene/CurrentScreen
@onready var menu = $Menu
@onready var screenAnim = $ScreenFX/ScreenAnimation
@onready var world = $CurrentScene/World

func _ready():
	playerPokemon.append(pokemon.new("Bulbasaur", 10))
	screenAnim.play("Loading")

#Updates FPS counter every process
func _process(delta):
	$FPS.text = str(Engine.get_frames_per_second())

func _input(event):
	if(event.is_action_pressed("testCombat")):
		initiateCombat(pokemon.new("Bulbasaur", 10))

func loadScreen(path):
	screenNode.add_child(load(path).instantiate())
	menu.enabled = false
	menu.visible = false
	world.process_mode = PROCESS_MODE_DISABLED

func initiateCombat(enemy):
	screenAnim.play("StartCombat")
	await screenAnim.animation_finished
	loadScreen("res://Scenes/Combat/combat_scene.tscn")
	startCombat(playerPokemon[0], enemy)
	screenAnim.play("FadeToCombat")

func fadeFromCombat():
	screenAnim.play("FadeFromCombat")
	SignalManager.combatDone.emit()
	exitScreen()
	
func startCombat(playerPokemon, enemyPokemon):
	$CurrentScene/CurrentScreen/Combat.startCombat(playerPokemon, enemyPokemon)

func exitScreen():
	screenNode.clearScreens()
	menu.enabled = true
	menu.visible = true
	world.process_mode = PROCESS_MODE_INHERIT

func checkLoad():
	$Timer.start()
	await $Timer.timeout
	$Timer.queue_free()
	screenAnim.play("FadeFromLoading")
