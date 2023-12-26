extends CanvasLayer

signal pressedComfirm
signal moveDone
signal statusDone

@onready var enemySprite = $Enemy/Sprite2D
@onready var playerSprite = $Player/Sprite2D
@onready var UI = $UI

@onready var enemy : battlePlayer = $Enemy
@onready var player : battlePlayer = $Player

var moveQueue = []
@onready var battlerQueue = [player, enemy]

func _ready():
	player.generateBack = true
	enemy.enemy = true
	player.UI = UI
	enemy.UI = UI
	player.opponent = enemy
	enemy.opponent = player

func _input(event):
	if event.is_action_pressed("confirm"):
		pressedComfirm.emit()

func startCombat(playerPokemon, enemyPokemon):
	enemy.loadPokemon(enemyPokemon)
	player.loadPokemon(playerPokemon)
	loadMoves(player)

func resolveQueue():
	var deadPlayer : battlePlayer
	for move in moveQueue:
		preMoveUse(move[0], move[1], move[2])
		await moveDone
		
		for battler in battlerQueue:
			if(battler.getHP() == 0):
				deadPlayer = battler
				break
		if(deadPlayer != null):
			break
	
	if(deadPlayer == null):
		for battler in battlerQueue:
			if(battler.getStatuses() != []):
			
				for status in battler.getStatuses():
					var statusPassed = status._effect_afterMoves(battler, battler.opponent, UI)
				
					if(statusPassed):
						await pressedComfirm
					
					if(battler.getHP() == 0):
						deadPlayer = battler
						break
			if(deadPlayer != null):
				break
				
		if(deadPlayer == null):
			UI.showMenu()
		
	if(deadPlayer != null):
		UI.setDialog("%s fainted!" % deadPlayer.getName())
		await pressedComfirm
		UI.clearAll()
		deadPlayer.deathTween()
	
	moveQueue = []

#Overview from pokemon showdown
#Pre-Move interruptions, ex. flinch/paralysis
#Move Usage
#Internal interruption, ex. solar beam charge
#Sub-Move start (Metronome, Sleep Talk)
#Move Execution
#Is there a target still?
#PP deduction
#Move Hit
#Check if misses
#External failure Ex. Protect, Substitute
#Immunity
#Animation/Damage
#Healing, Status Effects
#Recoil, Drain Heals

func preMoveUse(move : Dictionary, attacker : battlePlayer, victim : battlePlayer):
	UI.showDialog()
	UI.setDialog(attacker.getName() + " used " + move.DisplayName + "!")
	moveUse(move, attacker, victim)
	
func moveUse(move : Dictionary, attacker : battlePlayer, victim : battlePlayer):
	moveExectute(move, attacker, victim)

func moveExectute(move : Dictionary, attacker : battlePlayer, victim : battlePlayer):
	move.PP[0] -= 1
	
	if(move.PP[0] < 0):
		move.PP[0] = 0
	
	moveHit(move, attacker, victim)

func moveHit(move : Dictionary, attacker : battlePlayer, victim : battlePlayer):
	
	var outcome = calculateDamage(move, attacker, victim)
	
	if(outcome[0] > 0):
		victim.reduceHP(outcome[0])
		print(outcome)
		
	await pressedComfirm
	
	if(outcome[1] != 1):
		if(outcome[1] == 0):
			UI.setDialog("It doesn't affect the opposing %s..." % [victim.getName()])
			await pressedComfirm
		elif(outcome[0] > 0):
			UI.setDialog(MasterInfo.effectiveDialog.get(str(clamp(outcome[1], 0.5, 2))))
			await pressedComfirm
	
	if(move.StatChanges != {} and outcome[1] != 0):
		changeStats(move, attacker, victim)
		await statusDone
	
	moveDone.emit()

func calculateDamage(move : Dictionary, attacker : battlePlayer, victim : battlePlayer):
	
	var damage = 2.0
	var level = float(attacker.getLevel())
	var power = float(move.Power)
	var attack
	var defense
	
	#Determines Type Effectiveness
	var typeMatchups = MasterInfo.typeMatchups.get(move.Type)
	var typeMultiplier = 1.0
	
	for type in victim.getTypes():
		if(typeMatchups.has(type)):
			typeMultiplier *= float(typeMatchups.get(type))
	
	if(move.Category == "Physical"):
		attack = float(attacker.getAttack())
		defense = float(victim.getDefense())
	elif(move.Category == "Special"):
		attack = float(attacker.getSpAttack())
		defense = float(victim.getSpDefense())
	else:
		return [0, typeMultiplier]
	
	if(move.Flags.has("useDefense")):
		defense = float(victim.def)
	
	#The big part of the damage formula
	damage *= level
	damage /= 5.0
	damage += 2.0
	damage *= power
	damage *= float(attack/defense)
	damage /= 50.0
	damage += 2.0
	#Multipliers
	
	#Burn
	if(attacker.statusEffect != null):
		if(attacker.statusEffect.reduceDamage and move.Category == "Physical"):
			damage /= 2
	
	#Critical
	
	#Random
	damage = damage * (randf_range(85, 100)/100.0)
	
	#STAB
	if(attacker.getTypes().has(move.Type)):
		damage = float(damage) * 1.5
		
	#Type Effectiveness
	damage = damage * typeMultiplier
	
	damage = floor(damage)
	
	return [int(damage), typeMultiplier]

func changeStats(move : Dictionary, attacker : battlePlayer, victim : battlePlayer):
	var statChanges = move.StatChanges
	
	#Go through each chance as its own step
	for chance in statChanges.keys():
		var statChange = statChanges.get(chance)
		var target
		
		#Go through each step of the change
		for step in statChange.keys():
			var change = statChange.get(step)
			var hasStartMessage = false
			
			if(step == "Target"):
				target = change

			elif(target == "Victim"):
				if(step == "VolatileEffect"):
					hasStartMessage = inflictVolatile(victim, change)
					
				elif(step == "StatusEffect"):
					hasStartMessage = inflictStatus(victim, change)
					
				else:
					victim.changeStat(step, int(change))
					UI.setDialog(MasterInfo.changesDialog.get(str(clamp(change, -3, 3))) % [victim.getName(), step])
					hasStartMessage = true
					
				if(hasStartMessage):
					await pressedComfirm
						
			elif(target == "Self"):
				if(step == "VolatileEffect"):
					hasStartMessage = inflictVolatile(attacker, change)
					
				elif(step == "StatusEffect"):
					hasStartMessage = inflictStatus(attacker, change)
					
				else:
					attacker.changeStat(step, int(change))
					UI.setDialog(MasterInfo.changesDialog.get(str(clamp(change, -3, 3))) % [attacker.getName(), step])
					hasStartMessage = true
					
				if(hasStartMessage):
					await pressedComfirm
					
	statusDone.emit()

func inflictVolatile(target : battlePlayer, change):
	var statusMessage = target.inflictVolatile(change)
	return statusMessage

func inflictStatus(target : battlePlayer, change):
	var statusMessage = target.inflictStatus(change)
	return statusMessage

func loadMoves(battleNode : battlePlayer):
	var moves = battleNode.getMoves()
	
	var buttons = [$UI/Fight/Fight/Attack1, $UI/Fight/Fight/Attack2, $UI/Fight/Fight/Attack3, $UI/Fight/Fight/Attack4]
	
	for button in buttons:
		button.visible = true
	
	for move in moves:
		buttons[0].storedMove = move
		buttons[0].text = move.DisplayName
		buttons.pop_front()
	
	if(buttons.size() > 0):
		for button in buttons:
			button.visible = false

func decideAIMove(attacker : battlePlayer, victim : battlePlayer):
	var move = attacker.getMoves().pick_random()
	
	if(move.Target == "Self"):
		moveQueue.append([move, attacker, attacker])
		#preMoveUse(move, enemy, enemy)
	else:
		moveQueue.append([move, attacker, victim])
		#preMoveUse(move, enemy, player)

func _on_move_pressed(move : Dictionary):
	if(move.PP[0] <= 0):
		pass
	else:
		var queue
		if(move.Target == "Self"):
			moveQueue.append([move, player, player])
		else:
			moveQueue.append([move, player, enemy])
		
		decideAIMove(enemy, player)
		resolveQueue()
