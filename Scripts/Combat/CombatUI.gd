extends Control

func setDialog(text):
	$Dialog/DialogText.text = str(text)

func showDialog():
	$Dialog.show()
	$Fight.hide()
	$Menu.hide()

func showMenu():
	$Menu.show()
	$Fight.hide()
	$Dialog.hide()

func _on_fight_pressed():
	$Fight.show()
	$Menu.hide()
	$Dialog.hide()

func _on_back_pressed():
	$Menu.show()
	$Fight.hide()
	$Dialog.hide()