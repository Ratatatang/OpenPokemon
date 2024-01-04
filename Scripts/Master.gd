extends Node3D

var player 
var playerPokemon = []

@onready var screenNode = $CurrentScene/CurrentScreen
@onready var menu = $Menu
@onready var screenAnim = $ScreenFX/ScreenAnimation
@onready var world = $CurrentScene/World

func _ready():
	playerPokemon.append(pokemon.new("Pidgey", 10))
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
	var playerFirst
	for member in playerPokemon:
		if(!member.getHP() <= 0):
			playerFirst = member
			break
	
	if(playerFirst == null):
		return
	
	screenAnim.play("StartCombat")
	await screenAnim.animation_finished
	loadScreen("res://Scenes/Combat/combat_scene.tscn")
	startCombat(playerFirst, enemy)
	screenAnim.play("FadeToCombat")

func fadeFromCombat():
	screenAnim.play("FadeFromCombat")
	SignalManager.combatDone.emit()
	exitScreen()
	
func startCombat(playerPokemon, enemyPokemon):
	$CurrentScene/CurrentScreen/Combat.startCombat(playerPokemon, enemyPokemon)

func distributeXP(defeated : pokemon):
	for member in playerPokemon:
		if(member.participant):
			var exp = float(defeated.getBaseExp())
			var level = float(defeated.getLevel())
			exp *= level
			exp /= 5.0
			#S, should be 1, 2 if exp share. 1/S
			
			var levelMultiplier = (level * 2.0)
			levelMultiplier += 10.0
			
			var levelDivider = level
			levelDivider += float(member.getLevel())
			levelDivider += 10.0
			
			exp *= (levelMultiplier/levelDivider) ** 2.5
			exp += 1.0
			
			member.calculateLevel(floor(exp))

func exitScreen():
	screenNode.clearScreens()
	menu.enabled = true
	world.process_mode = PROCESS_MODE_INHERIT

func checkLoad():
	$Timer.start()
	await $Timer.timeout
	$Timer.queue_free()
	screenAnim.play("FadeFromLoading")
