extends Control

signal switchOut(selectedPokemon)

var charLimit = 20

var loadedPokemon
var switchMode

func init(pokemonInst):
	loadedPokemon = pokemonInst
	#Sets the sprite, and the amount of frames (for pokemon that have alt looks for gender)
	var newSprite = "res://Assets/2DScreens/PokemonScreen/PokemonIcons/%s.png" % loadedPokemon.speciesName.to_upper()
	$Sprite2D.texture = load(newSprite)
	
	$Name.text = loadedPokemon.displayName
	
	if(loadedPokemon.gender == "Female"):
		$GenderIcons.frame = 1
		
	$HealthBar.value = (loadedPokemon.tempHp / loadedPokemon.hp) * 1000
	
	$HealthBar/HealthNumber.text = str(loadedPokemon.tempHp)+"/"+str(loadedPokemon.hp)
	$Level.text = "Level: "+str(loadedPokemon.level)
	
	$Choices/Swap.text = "Swap In"
	if(switchMode == "Dead"):
		$Choices/Swap.text = "Unable"
		$Choices/Swap.disabled = true
	elif(switchMode == "Battling"):
		$Choices/Swap.text = "Battling"
		$Choices/Swap.disabled = true

func _on_texture_button_pressed():
	$Choices.visible = true

func _on_swap_pressed():
	switchOut.emit(loadedPokemon)
	
func _on_texture_button_focus_exited():
	if($Choices.visible == true):
		$Timer.start()
		await $Timer.timeout
		$Choices.visible = false
