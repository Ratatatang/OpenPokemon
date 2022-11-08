extends Node2D

var chaLimit = 20

func init(pokemon):
	$Sprite.texture = load("res://Combat/Sprites/"+pokemon.pokedexInfo.get("ID")+".png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
