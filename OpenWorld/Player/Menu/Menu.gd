extends CanvasLayer

onready var selectionArrow = $Menu/NinePatchRect/Arrow
onready var menu = $Menu

onready var partyScreen = load("res://OpenWorld/Player/Menu/Menus/TestScreen/TestScreen.tscn")
onready var inventory = load("res://OpenWorld/Player/Menu/Menus/TestScreen/TestScreen.tscn")
onready var journal = load("res://OpenWorld/Player/Menu/Menus/TestScreen/TestScreen.tscn")
onready var settings = load("res://OpenWorld/Player/Menu/Menus/TestScreen/TestScreen.tscn")
onready var save = load("res://OpenWorld/Player/Menu/Menus/TestScreen/TestScreen.tscn")


onready var options = [partyScreen, inventory, journal, settings, save]
 
enum ScreenLoaded {NOTHING, JUST_MENU, PARTY_SCREEN, INV_SCREEN, JOURNAL_SCREEN, SETTINGS_SCREEN, SAVE_SCREEN}
var screen_loaded = ScreenLoaded.NOTHING

var selected_option = 0

var enabled = true

func _ready():
	menu.visible = false
	selectionArrow.rect_position.y = 11 + (selected_option % 5) * 15

func _unhandled_input(event) -> void:
	if(enabled == false):
		return
	match screen_loaded:
		ScreenLoaded.NOTHING:
			if event.is_action_pressed("openMenu"):
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU
				
		
		ScreenLoaded.JUST_MENU:
			if event.is_action_pressed("openMenu"):
				menu.visible = false
				screen_loaded = ScreenLoaded.NOTHING
			elif event.is_action_pressed("ui_accept"):
				menu.visible = false
				var loadScreen = options[selected_option]
				get_parent().loadScreen(loadScreen)
				
				if(selected_option == 0):
					screen_loaded = ScreenLoaded.PARTY_SCREEN
				if(selected_option == 1):
					screen_loaded = ScreenLoaded.INV_SCREEN
				if(selected_option == 2):
					screen_loaded = ScreenLoaded.JOURNAL_SCREEN
				if(selected_option == 3):
					screen_loaded = ScreenLoaded.SETTINGS_SCREEN
				if(selected_option == 4):
					screen_loaded = ScreenLoaded.SAVE_SCREEN
	
				
			elif event.is_action_pressed("ui_down"):
				if selected_option == 4:
					selected_option = -1
				selected_option += 1
				selectionArrow.rect_position.y = 11 + (selected_option % 5) * 15
				
			elif event.is_action_pressed("ui_up"):
				if selected_option == 0:
					selected_option = 4
				else:
					selected_option -= 1
			selectionArrow.rect_position.y = 11 + (selected_option % 5) * 15
					
		ScreenLoaded.PARTY_SCREEN:
			if event.is_action_pressed("openMenu"):
				get_parent().exitScreen()
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU
				
		ScreenLoaded.INV_SCREEN:
			if event.is_action_pressed("openMenu"):
				get_parent().exitScreen()
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU
				
		ScreenLoaded.JOURNAL_SCREEN:
			if event.is_action_pressed("openMenu"):
				get_parent().exitScreen()
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU
				
		ScreenLoaded.SETTINGS_SCREEN:
			if event.is_action_pressed("openMenu"):
				get_parent().exitScreen()
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU
				
		ScreenLoaded.SAVE_SCREEN:
			if event.is_action_pressed("openMenu"):
				get_parent().exitScreen()
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU
