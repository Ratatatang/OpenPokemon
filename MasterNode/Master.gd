extends Spatial

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 6

var server = null
var client = null

var ip_address = ""

var player_name = "Unnamed"

var players = {}

var connectedToServer = false

signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal connected_to_multiplayer()

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
onready var worldGenerator = $"CurrentScene/World/World Generator"

var pokemon

func _init():
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
	
	pokemon = load("res://MasterNode/PokemonClass.gd")

func _ready():
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
#	get_tree().connect("connection_failed", self, "_connection_failed")

	screenEffectPlayer.play("Reset")

	playerPokemonList[0] = pokemon.new(pokedex, movedex, "Pidgey", 13)


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
		callWildEncounter("Bulbasaur")

func callWildEncounter(species, lv = 0):
	menu.enabled = false
	player.external_set_state("freeze")
	screenEffectPlayer.play("WildCombatStart")
	yield(screenEffectPlayer, "animation_finished")
	currentScene.add_child(load(combatScenePath).instance())
	var combatScene = currentScene.get_node("CombatScene")
	combatScene.wild_combat_start(playerPokemonList, pokemon.new(pokedex, movedex, species, lv))
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

func getPokemon(species, lv = 0):
	return pokemon.new(pokedex, movedex, species, lv)


func host_game(new_name):
	player_name = new_name
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)
	setupMultiplayer()
	setupHost()
	connectedToServer = true
	
func join_game(con_ip_address, new_name):
	player_name = new_name
	client = NetworkedMultiplayerENet.new()
	client.create_client(con_ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	setupMultiplayer()

func setupMultiplayer():
	player.name += player_name
	player.set_name(player_name)
	player.set_network_master(get_tree().get_network_unique_id())
	player.startTimer()
#	worldGenerator.set_network_master(1)

func setupHost():
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for i in save_nodes:
		i.set_network_master(1)
		i.startTimer()

func _connected_to_server():
	connectedToServer = true
	print("--Connected To Server!")
	rpc("sendMap", get_tree().get_network_unique_id())

func _server_disconnected():
	connectedToServer = false
	print("--Disconnected From Server!")

func _player_connected(id):
	print("--Peer Connected! ID: "+str(id))
	rpc("register_player", player_name)
	

func _player_disconnected(id):
	print("--Peer Disconnected! ID: "+str(id))
	unregister_player(id)

func get_player_list():
	return players.values()

func get_player_name():
	return player_name

remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	players[id] = new_player_name
	emit_signal("player_list_changed")
	addPlayer(id)

func addPlayer(id):
	var newPlayer = worldGenerator.addPlayer(players[id])
	newPlayer.set_network_master(id)

func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")

master func sendMap(id):
	worldGenerator.loadMaptoID(id)

func generateMap():
	worldGenerator.regenerateMap(player)

func finishedMap():
	print("--finished map!")
	rpc("generateObjects", get_tree().get_network_unique_id())

master func generateObjects(id):
	print("--generating objects!")
	worldGenerator.loadChildrenToID(id)

func multiplayerReady():
	menu.multiplayerReady = true
