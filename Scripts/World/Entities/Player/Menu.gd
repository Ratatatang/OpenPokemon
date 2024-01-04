extends CanvasLayer

@onready var selectionArrow = $Menu/NinePatchRect/Arrow
@onready var menu = $Menu

@onready var partyScreen = "res://Scenes/2DScreens/PokemonScreen/PokemonScreen.tscn"
@onready var crafting = "res://Scenes/2DScreens/TestScreen.tscn"
@onready var journal = "res://Scenes/2DScreens/TestScreen.tscn"
@onready var settings = "res://Scenes/2DScreens/TestScreen.tscn"
@onready var save = "res://Scenes/2DScreens/TestScreen.tscn"

@onready var options = [partyScreen, crafting, journal, settings, save]
 
enum ScreenLoaded {NOTHING, JUST_MENU, PARTY_SCREEN, CRAFT_SCREEN, JOURNAL_SCREEN, SETTINGS_SCREEN, SAVE_SCREEN}
var screen_loaded = ScreenLoaded.NOTHING

var multiplayerReady = true

var selected_option = 0

var enabled = true

func _ready():
	menu.visible = false
	selectionArrow.position.y = 7.5 + (selected_option % 5) * 17.4

func _input(event) -> void:
	if(enabled == false and screen_loaded == ScreenLoaded.NOTHING):
		menu.visible = false
		return
	match screen_loaded:
		ScreenLoaded.NOTHING:
			if event.is_action_pressed("menu"):
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU


		ScreenLoaded.JUST_MENU:
			if event.is_action_pressed("menu"):
				menu.visible = false
				screen_loaded = ScreenLoaded.NOTHING
			elif event.is_action_pressed("confirm"):
				menu.visible = false
				var loadScreen = options[selected_option]
				get_parent().loadScreen(loadScreen)

				if(selected_option == 0):
					screen_loaded = ScreenLoaded.PARTY_SCREEN
				if(selected_option == 1):
					screen_loaded = ScreenLoaded.CRAFT_SCREEN
				if(selected_option == 2):
					screen_loaded = ScreenLoaded.JOURNAL_SCREEN
				if(selected_option == 3):
					screen_loaded = ScreenLoaded.SETTINGS_SCREEN
				if(selected_option == 4):
					screen_loaded = ScreenLoaded.SAVE_SCREEN
					
#			elif event.is_action_pressed("scrolldown") or event.is_action_pressed("ui_down")
			elif event.is_action_pressed("scrolldown"):
				if selected_option == 4:
					selected_option = -1
				selected_option += 1
				selectionArrow.position.y = 7.5 + (selected_option % 5) * 17.4
				
#			elif event.is_action_pressed("scrollup") or event.is_action_pressed("ui_up"):
			elif event.is_action_pressed("scrollup"):
				if selected_option == 0:
					selected_option = 4
				else:
					selected_option -= 1
			selectionArrow.position.y = 7.5 + (selected_option % 5) * 17.4

		ScreenLoaded.PARTY_SCREEN:
			if event.is_action_pressed("menu"):
				get_parent().exitScreen()
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU

		ScreenLoaded.CRAFT_SCREEN:
			if event.is_action_pressed("menu"):
				get_parent().exitScreen()
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU

		ScreenLoaded.JOURNAL_SCREEN:
			if event.is_action_pressed("menu"):
				get_parent().exitScreen()
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU

		ScreenLoaded.SETTINGS_SCREEN:
			if event.is_action_pressed("menu") and multiplayerReady:
				get_parent().exitScreen()
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU

		ScreenLoaded.SAVE_SCREEN:
			if event.is_action_pressed("menu"):
				get_parent().exitScreen()
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU

func toggleMenu(visiblity = !menu.visible):
	menu.visible = visiblity
