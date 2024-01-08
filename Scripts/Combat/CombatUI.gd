extends Control

func setDialog(text):
	$Dialog/DialogText.text = str(text)

func clearAll():
	$Dialog.hide()
	$Fight.hide()
	$Menu.hide()
	$Switch.hide()
	
func showDialog():
	$Dialog.show()
	$Fight.hide()
	$Menu.hide()
	$Switch.hide()

func showMenu():
	$Menu.show()
	$Fight.hide()
	$Dialog.hide()
	$Switch.hide()

func showFight():
	$Fight.show()
	$Menu.hide()
	$Dialog.hide()
	$Switch.hide()

func showSwitch():
	$Switch.show()
	$Switch.loadPokemon()
	$Fight.hide()
	$Menu.hide()
	$Dialog.hide()

func _on_fight_pressed():
	$Fight.show()
	$Menu.hide()
	$Dialog.hide()
	$Switch.hide()

func _on_back_pressed():
	$Menu.show()
	$Fight.hide()
	$Dialog.hide()
	$Switch.hide()

func _on_pokemon_pressed():
	$Switch.show()
	$Switch.loadPokemon()
	$Menu.hide()
	$Fight.hide()
	$Dialog.hide()
