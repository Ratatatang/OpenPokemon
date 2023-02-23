extends Spatial

const DEFAULT_PORT = 10567
const MAX_PEERS = 12

var peer = null
var player_name = "Unnamed"

var players = {}

signal player_list_changed()
signal connection_failed()
signal connection_succeeded()

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

var pokemon

func _ready():
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	pokemon = load("res://MasterNode/PokemonClass.gd")
	
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


#Updates FPS counter every process
func _process(delta):
	$FPS_Counter.text = str(Engine.get_frames_per_second())
	
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
		callWildEncounter("Bulbasaur", 13)

func callWildEncounter(species, lv):
	menu.enabled = false
	player.external_set_state("freeze")
	screenEffectPlayer.play("WildCombatStart")
	yield(screenEffectPlayer, "animation_finished")
	currentScene.add_child(load(combatScenePath).instance())
	var combatScene = currentScene.get_node("CombatScene")
	combatScene.wild_combat_start(playerPokemonList, pokemon.new(species, lv, pokedex, movedex))
	combatScene.connect("finished_combat", self, "fade_from_combat")
	combatScene.connect("xp", self, "givePokemonXP")
	combatScene.connect("lose_combat", self, "lose_from_combat")
	combatScene.connect("caught_pokemon", self, "capturePokemon")

	screenEffectPlayer.play("FadeToCombat")
	
func fade_from_combat():
	$ScreenEffects/ColorRect.visible = true
	screenEffectPlayer.play("FadeToBlack")
	
	yield(screenEffectPlayer, "animation_finished")

	for i in range(len(playerPokemonList)):
		if(typeof(playerPokemonList[i]) != TYPE_STRING):
			playerPokemonList[i].participant = false
	
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
	
func givePokemonXP(victim):
	var base = float(victim.pokedexInfo.XPValue)
	var lv = float(victim.level)
	
	print("Adding Xp from base: " + str(base) +" level: "+str(lv))
	
	for i in range(len(playerPokemonList)):
		
		var currentPokemon = playerPokemonList[i]
		if(typeof(currentPokemon) != TYPE_STRING):
			
			print("Found Pokemon")
			
			var contribute
			
			print("contributed: "+ str(currentPokemon.participant))
			
			if(currentPokemon.participant == true):
				contribute = 1.0
			else:
				contribute = 2.0
				
			var victor = currentPokemon.level
			
			#I have a deep hatred of everything
			var addedXp = round((((base * lv)/5.0) * (1.0/contribute)) * pow((((2.0*1.0)+10.0)/(1.0+victor+10.0)), 2.5) + 1.0)

			currentPokemon.calculateLevel(addedXp)
	
func host_game(new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)

func join_game(ip, new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
func get_player_list():
	return players.values()
	
func get_player_name():
	return player_name

func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", player_name)

func _player_disconnected(id):
	unregister_player(id)

remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	print(id)
	players[id] = new_player_name
	emit_signal("player_list_changed")

func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")
	
func _connected_ok():
	emit_signal("connection_succeeded")
	
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")
