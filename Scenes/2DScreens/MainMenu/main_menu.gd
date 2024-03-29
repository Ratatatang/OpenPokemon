extends Node2D

signal tweenDone

var pokemonNames
var currentPokemon

func _ready():
	var frames = $SetDressing/WanderingPokemon/Walkies.sprite_frames
	var walkies = $SetDressing/WanderingPokemon/Walkies
	pokemonNames = MasterInfo.getAllPokemon()
	
	loadAnimated()
	
	walkies.play("default")
	
	while(true):
		walking()
		await tweenDone
		frames.clear("default")
		loadAnimated()

func loadAnimated():
	var frames = $SetDressing/WanderingPokemon/Walkies.sprite_frames
	var spriteSheet = "res://Assets/World/Entities/Pokemon/Walking/%s.png"
	
	currentPokemon = pokemonNames.pick_random().to_upper()
	var sprite = load(spriteSheet % currentPokemon)
	
	for i in 4:
		var atlas = AtlasTexture.new()
		atlas.atlas = sprite
		atlas.region = Rect2((64*i), 128, 64, 64)
		frames.add_frame("default", atlas)

func walking():
	var tween = create_tween()
	var walkies = $SetDressing/WanderingPokemon/Walkies
	
	tween.tween_property(walkies, "position", Vector2(125, walkies.position.y), 13)
	await tween.finished
	walkies.position.x = -117
	tweenDone.emit()

func _on_start_pressed():
	var master = load("res://Scenes/Master.tscn")
	get_tree().change_scene_to_packed(master)
