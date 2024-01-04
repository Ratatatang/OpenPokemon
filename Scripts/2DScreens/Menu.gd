extends CanvasLayer

@onready var partyScreen = "res://Scenes/2DScreens/PokemonScreen/PokemonScreen.tscn"
@onready var crafting = "res://Scenes/2DScreens/TestScreen.tscn"
@onready var journal = "res://Scenes/2DScreens/TestScreen.tscn"
@onready var settings = "res://Scenes/2DScreens/TestScreen.tscn"
@onready var save = "res://Scenes/2DScreens/TestScreen.tscn"

@onready var pokemonScreen = $PokemonScreen

enum ScreenLoaded {NOTHING, JUST_MENU, PARTY_SCREEN, CRAFT_SCREEN, JOURNAL_SCREEN, SETTINGS_SCREEN, SAVE_SCREEN, MAP_SCREEN}
var screenLoaded = ScreenLoaded.NOTHING
var screenSelected = screenLoaded.PARTY_SCREEN

var enabled = true

func _ready():
	visible = false

func _input(event) -> void:
	if(enabled == false and screenLoaded == ScreenLoaded.NOTHING):
		visible = false
		return
	match screenLoaded:
		ScreenLoaded.NOTHING:
			if event.is_action_pressed("menu"):
				visible = true
				pokemonScreen.loadPokemon(get_node("/root/Master").playerPokemon)
				$MenuTabs/Bag.grab_focus()
				screenLoaded = screenSelected
				
		ScreenLoaded.PARTY_SCREEN:
			if event.is_action_pressed("menu"):
				visible = false
				screenLoaded = ScreenLoaded.NOTHING
				screenSelected = ScreenLoaded.PARTY_SCREEN
		
		ScreenLoaded.MAP_SCREEN:
			if event.is_action_pressed("menu"):
				visible = false
				screenLoaded = ScreenLoaded.NOTHING
				screenSelected = ScreenLoaded.MAP_SCREEN


func _on_bag_pressed():
	pass # Replace with function body.
