extends Node2D

var chaLimit = 20

func init(pokemon):
	#Sets the sprite, and the amount of frames (for pokemon that have alt looks for gender)
	var newSprite = load("res://Combat/Sprites/"+pokemon.pokedexInfo.get("ID")+".png")
	$Name.text = pokemon.displayName
	$Sprite.texture = newSprite
	if(newSprite.get_height() > 64):
		$Sprite.vframes = 2
		if(pokemon.gender == "Female"):
			$Sprite.frame = 4
	else:
		$Sprite.vframes = 1
	
	if(pokemon.gender == "Female"):
		$GenderIcons.frame = 1
		
	$HealthBar.value = round($HealthBar.value * (pokemon.tempHp/pokemon.hp))
	$XPBar.value = round($XPBar.value * (pokemon.xp/pokemon.neededXP))
	
	$HealthBar/HealthNumber.text = str(pokemon.tempHp)+"/"+str(pokemon.hp)
	$XPBar/Level.text = "Level: "+str(pokemon.level)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
