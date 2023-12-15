extends CanvasLayer

@onready var enemySprite = $Enemy/Sprite2D
@onready var playerSprite = $Player/Sprite2D

@onready var enemy = $Enemy
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	enemySprite.texture = load("res://Assets/Combat/Pokemon/Front/BULBASAUR.png")
	playerSprite.texture = load("res://Assets/Combat/Pokemon/Back/BULBASAUR.png")
	enemy.loadPokemon()
	player.loadPokemon()
	loadMoves(player)

func loadMoves(pokeNode):
	var moves = pokeNode.getMoves().values()
	
	var buttons = [$UI/Fight/Fight/Attack1, $UI/Fight/Fight/Attack2, $UI/Fight/Fight/Attack3, $UI/Fight/Fight/Attack4]
	
	for button in buttons:
		button.visible = true
	
	for move in moves:
		move = MasterInfo.getMove(move)
		buttons[0].storedMove = move
		buttons[0].text = move.DisplayName
		buttons.pop_front()
	
	if(buttons.size() > 0):
		for button in buttons:
			button.visible = false

func calculateDamage(move):
	pass

func _on_move_pressed(move):
	pass
