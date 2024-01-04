extends Node2D

var charLimit = 20

var loadedPokemon

func init(pokemonInst):
	loadedPokemon = pokemonInst
	#Sets the sprite, and the amount of frames (for pokemon that have alt looks for gender)
	var newSprite = load("res://Assets/Combat/Pokemon/Front/%s.png" % loadedPokemon.speciesName.to_upper())
	$Name.text = loadedPokemon.displayName
	$Sprite2D.texture = newSprite
	
	if(loadedPokemon.gender == "Female"):
		$GenderIcons.frame = 1
		
	$HealthBar.value = (loadedPokemon.tempHp / loadedPokemon.hp) * 1000
	
	#$XPBar.value = round($XPBar.value * ((loadedPokemon.xp-loadedPokemon.neededXP)/loadedPokemon.neededXP))
	$XPBar.value = ((loadedPokemon.xp-loadedPokemon.calculateXP()) / loadedPokemon.neededXP) * 1000
	
	$HealthBar/HealthNumber.text = str(loadedPokemon.tempHp)+"/"+str(loadedPokemon.hp)
	$XPBar/Level.text = "Level: "+str(loadedPokemon.level)
