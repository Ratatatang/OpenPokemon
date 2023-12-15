extends Node2D

var chaLimit = 20

func init(pokemon):
	#Sets the sprite, and the amount of frames (for pokemon that have alt looks for gender)
	var newSprite = load("res://Combat/Sprites/Front/"+pokemon.speciesName.to_upper()+".png")
	$Name.text = pokemon.displayName
	$Sprite2D.texture = newSprite
	
	if(pokemon.dimorphism):
		if(pokemon.gender == "Female"):
			load("res://Combat/Sprites/Front/"+pokemon.speciesName.to_upper()+"_female.png")
	
	if(pokemon.gender == "Female"):
		$GenderIcons.frame = 1
		
	$HealthBar.value = round($HealthBar.value * (pokemon.tempHp/pokemon.hp))
	$XPBar.value = round($XPBar.value * ((pokemon.xp-pokemon.neededXP)/pokemon.neededXP))
	
	$HealthBar/HealthNumber.text = str(pokemon.tempHp)+"/"+str(pokemon.hp)
	$XPBar/Level.text = "Level: "+str(pokemon.level)
