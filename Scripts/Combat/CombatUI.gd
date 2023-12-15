extends Control


func _on_fight_pressed():
	$Menu.hide()
	$Fight.show()


func _on_back_pressed():
	$Fight.hide()
	$Menu.show()
