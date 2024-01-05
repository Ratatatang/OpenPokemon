extends CanvasLayer

@onready var pokemonScreen = $PokemonScreen
@onready var map = $MapScreen
@onready var crafting
@onready var journal
@onready var settings 
@onready var save

#@onready var screens = [pokemonScreen, map, crafting, journal, settings, save]
@onready var screens = [pokemonScreen, map]

enum ScreenLoaded {NOTHING, JUST_MENU, PARTY_SCREEN, CRAFT_SCREEN, JOURNAL_SCREEN, SETTINGS_SCREEN, SAVE_SCREEN, MAP_SCREEN}
var screenLoaded = ScreenLoaded.NOTHING
var screenSelected = ScreenLoaded.PARTY_SCREEN

var enabled = true

func _ready():
	visible = false

func _input(event) -> void:
	if event.is_action_pressed("menu"):
		reloadScreens("menu")

func reloadScreens(event):
	if(enabled == false and screenLoaded == ScreenLoaded.NOTHING):
		visible = false
		return
	match screenLoaded:
		ScreenLoaded.NOTHING:
			if event == "menu":
				visible = true
				pokemonScreen.loadPokemon(get_node("/root/Master").playerPokemon)
				screenLoaded = screenSelected
				
		ScreenLoaded.PARTY_SCREEN:
			if event == "menu":
				visible = false
				screenLoaded = ScreenLoaded.NOTHING
				screenSelected = ScreenLoaded.PARTY_SCREEN
			if event == "reload":
				hideAll()
				pokemonScreen.visible = true
		
		ScreenLoaded.MAP_SCREEN:
			if event == "menu":
				visible = false
				screenLoaded = ScreenLoaded.NOTHING
				screenSelected = ScreenLoaded.MAP_SCREEN
			if event == "reload":
				hideAll()
				map.visible = true

func hideAll():
	for screen in screens:
		screen.visible = false

func _on_bag_pressed():
	if(screenLoaded != ScreenLoaded.PARTY_SCREEN):
		screenLoaded = ScreenLoaded.PARTY_SCREEN
		reloadScreens("reload")


func _on_map_pressed():
	if(screenLoaded != ScreenLoaded.MAP_SCREEN):
		screenLoaded = ScreenLoaded.MAP_SCREEN
		reloadScreens("reload")
