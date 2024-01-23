extends Node2D

var charLimit = 20

var loadedPokemon

func init(pokemonInst):
	loadedPokemon = pokemonInst
	#Sets the sprite, and the amount of frames (for pokemon that have alt looks for gender)
	var newSprite = "res://Assets/2DScreens/PokemonScreen/PokemonIcons/%s.png" % loadedPokemon.speciesName.to_upper()
	$Sprite2D.texture = load(newSprite)
	
	$Name.text = loadedPokemon.displayName
	
	if(loadedPokemon.gender == "Female"):
		$GenderIcons.frame = 1
		
	$HealthBar.value = (loadedPokemon.tempHp / loadedPokemon.hp) * 1000
	
	#$XPBar.value = round($XPBar.value * ((loadedPokemon.xp-loadedPokemon.neededXP)/loadedPokemon.neededXP))
	$XPBar.value = ((loadedPokemon.xp-loadedPokemon.calculateXP()) / loadedPokemon.neededXP) * 1000
	
	$HealthBar/HealthNumber.text = str(loadedPokemon.tempHp)+"/"+str(loadedPokemon.hp)
	$XPBar/Level.text = "Level: "+str(loadedPokemon.level)
