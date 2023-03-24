extends Spatial

export var width = 100
export var height = 100

onready var tilemap = $GridMap
puppet var temperature = {}
puppet var altitude = {}
puppet var moisture = {}
var openSimplexNoise = OpenSimplexNoise.new()

puppet var globalSpawnPoint = Vector3.ZERO

var biomeTiles = {"Ocean": 0, "Plains": 1, "Beach": 2}
var tileBiomes = {-1: "", 0: "Ocean", 1: "Plains", 2: "Beach", 3: "Beach", 4: "Beach", 5: "Beach", 6: "Beach"}

var biomeData = {"Beach": load("res://OpenWorld/World Generation/BiomeData/Beach.gd"),
				 "Plains": load("res://OpenWorld/World Generation/BiomeData/Plains.gd"),
				 "Ocean": load("res://OpenWorld/World Generation/BiomeData/Ocean.gd")}
			
onready var playerObj = load("res://OpenWorld/Player/Player.tscn")

onready var masterNode = get_node("/root/Master")
onready var gameObjects = $GameObjects

var beachTiles = []
		
#Generates maps for temp, moisture & altitude used to decide biomes
func _ready():
	randomize()
	temperature = generateMap(450, 5)
	moisture = generateMap(450, 5)
	altitude = generateMap(180, 5)
	setTile(width, height)
	
	generateObjects(width, height)
	
	while(globalSpawnPoint == Vector3.ZERO):
		var point = Vector3(rand_range(1, 100), 0, rand_range(1, 100))
		if(getBiome(point) == "Beach"):
			globalSpawnPoint = point
	
	globalSpawnPoint = tilemap.map_to_world(globalSpawnPoint.x, 0.586, globalSpawnPoint.z)
	globalSpawnPoint.y = 0.586
		
	var newPlayer = addPlayer("")

#Generates 2D noise maps
func generateMap(per, oct):
	openSimplexNoise.seed = randi()
	openSimplexNoise.period = per
	openSimplexNoise.octaves = oct
	var gridName = {}
	
	for x in width:
		for z in height:
			var rand := 2*(abs(openSimplexNoise.get_noise_2d(x, z)))
			gridName[Vector2(x, z)] = rand
	return gridName
	

#Preliminary, sets every tile to be plains so there are no gaps in the world
func setTile(width, height):
	for x in width:
		for z in height:
			tilemap.set_cell_item(x, 0, z, biomeTiles.Plains)

#Sets the tile in accordance of the moisture, altitude, and temperature of the tile
	for x in width:
		for z in height:
			var pos = Vector2(x, z)
			var alt = altitude[pos]
			var temp = temperature[pos]
			var moist = moisture[pos]
			
			#Ocean
			if alt < 0.2:
				tilemap.set_cell_item(x, 0, z, biomeTiles.Ocean)
			
			#Beach
			elif between(alt, 0.2, 0.25):
				tilemap.set_cell_item(x, 0, z, biomeTiles.Beach)
				beachTiles.append(Vector3(x, 0, z))

			#Other Biomes
			elif alt > 0.25:
				
				#Plains
				#if between(moist, 0.2, 0.5) and between(temp, 0.2, 0.5):
				tilemap.set_cell_item(x, 0, z, biomeTiles.Plains)
					
				"""#Taiga Plains
				elif between(moist, 0, 0.2) and between(temp, 0.2, 0.4):
					tilemap.set_cellv(pos, biomeTiles.TaigaPlains)
				
				#Sulfur
				elif between(moist, 0.4, 0.9) and between(temp, 0.8, 0.9):
					tilemap.set_cellv(pos, biomeTiles.Sulfur)
					
				#Forest
				elif between(moist, 0.2, 0.7) and between(temp, 0.2, 0.6):
					tilemap.set_cellv(pos, biomeTiles.Forest)
				
				#Taiga
				elif between(moist, 0.3, 0.9) and between(temp, 0.1, 0.3):
					tilemap.set_cellv(pos, biomeTiles.Taiga)
					
				#Tundra
				elif between(moist, 0, 0.9) and between(temp, 0, 0.1):
					tilemap.set_cellv(pos, biomeTiles.Tundra)
					
				#Swamp
				elif between(moist, 0.6, 0.9) and between(temp, 0.3, 0.6):
					tilemap.set_cellv(pos, biomeTiles.Tundra)
				
				#Jungle
				elif between(moist, 0.4, 0.9) and between(temp, 0.6, 0.8):
					tilemap.set_cellv(pos, biomeTiles.Jungle)
				
				#Savannah
				elif between(moist, 0, 0.4) and between(temp, 0.4, 0.7):
					tilemap.set_cellv(pos, biomeTiles.Savannah)
				
				#Desert
				elif temp > 0.7 and moist < 0.4:
					tilemap.set_cellv(pos, biomeTiles.Desert)"""
	
	for i in beachTiles:
		autoTile(i)
			
				
#				if biome[Vector2(pos.x-1, pos.y-1)] == "Ocean" or biome[Vector2(pos.x-1, pos.y+1)] == "Ocean" or biome[Vector2(pos.x+1, pos.y-1)] == "Ocean" or biome[Vector2(pos.x+1, pos.y+1)] == "Ocean":
#					tilemap.set_cellv(pos, biomeTiles.Beach)

# Generates objects onto the tiles. trans is the Vector3 for putting the objects in their place and pos is for the biome map
func generateObjects(width, height):
	print("--generating objects")
	randomize()
	for x in width:
		for z in height:
			if(round(rand_range(0, 100)) < 70):
				continue
			else:
				var objectNum = round(rand_range(0, 100))
				var pos = Vector3(x, 0, z)
				
				if(groundTile(pos)):
					var possibleObjects
					var biome = biomeData.get(getBiome(pos)).new()
					var objects = biome.objects
					var keys = objects.keys()
					keys.sort()
					
					var num = rand_range(0, 100)
					
					for i in keys:
						if(i == keys[keys.size()-1]):
							possibleObjects = objects.get(i)
							break
						if(i >= num):
							possibleObjects = objects.get(i)
							break
						else:
							continue
					
					var newObject = load(possibleObjects[round(rand_range(0, possibleObjects.size()-1))])
					placeObject(newObject, pos)

#Helper func for start < val < end
func between(val, start, end):
	if start <= val and val <= end:
		return true

#Place an object that has a position relative to a different node
# EG: Adding a pokemon that is created inside the nest node
func placeForeignObject(newObject, pos : Vector3, biome = ""):
	placeObject(newObject, to_local(pos), biome)

func placeObject(objectPath, pos : Vector3, biome = ""):
	var newObject = objectPath.instance()
	#Holy Shit Transgender
	var realTrans = tilemap.map_to_world(pos.x, pos.y, pos.z)
	realTrans.x += rand_range(0, 0.3)
	realTrans.z += rand_range(0, 0.3)
	var objectTrans = realTrans
	objectTrans.y = newObject.translation.y
	newObject.global_translate(objectTrans)
	
	if(getBiome(tilemap.world_to_map(realTrans)) == biome or biome == ""):
		gameObjects.add_child(newObject)

# Place object, without the random tweaking
func placeObjectExact(objectPath, pos : Vector3):
	var newObject = objectPath.instance()
	var objectTrans = tilemap.map_to_world(pos.x, pos.y, pos.z)
	objectTrans.y = newObject.translation.y
	newObject.global_translate(objectTrans)
	gameObjects.add_child(newObject)

func addPlayer(playerName, pos = globalSpawnPoint):
	var newObject = playerObj.instance()
#	var objectTrans = tilemap.map_to_world(0, 0.586, 0)
	newObject.name += playerName
	$Players.add_child(newObject)
	
	newObject.set_spawn(pos, Vector3.ZERO)
	
	if(playerName != ""):
		newObject.set_name(playerName)
	
	return newObject

func groundTileGlobal(pos: Vector3):
	pos = tilemap.world_to_map(to_local(pos))
	return groundTile(pos)

func groundTile(pos : Vector3):
	if(getBiome(pos) !=  "Ocean"):
		return true
	return false
	
func waterTile(pos : Vector3):
	if(getBiome(pos) ==  "Ocean"):
		return true
	return false
	
func isTile(pos : Vector3, tile):
	if(tilemap.get_cell_item(pos.x, pos.y, pos.z) ==  tile):
		return true
	return false
	
func getBiome(pos: Vector3):
	return tileBiomes[tilemap.get_cell_item(pos.x, pos.y, pos.z)]

func loadMaptoID(id):
	
	print("--loading map")

	rset_id(id, "temperature", temperature)
	rset_id(id, "altitude", altitude)
	rset_id(id, "temperature", moisture)
	rset_id(id, "globalSpawnPoint", globalSpawnPoint)
	
	rpc_id(id, "clearChildren")
	

master func loadChildrenToID(id):
	var loadableNodes = []
	
	var save_nodes = get_tree().get_nodes_in_group("persist")
	print("--duplicating children")
	for i in save_nodes:
		i.name = i.name
		loadableNodes.append([i.path, i.name])
	
	rpc_id(id, "loadChildren", loadableNodes)

remote func regenerateMap(player):
	print("--remapping") 
	setTile(width, height)
	player.set_spawn(globalSpawnPoint, Vector2.ZERO)
	
	masterNode.finishedMap()

puppet func loadChild(loadables):
	print("--loading children")
	for i in loadables:
		var object = load(i[0]).instance()
		object.runReady = false
		object.set_network_master(1)
		object.name = i[1]
		gameObjects.add_child(object)
	
	masterNode.multiplayerReady()

puppet func clearChildren():
	print("--clearing children")
	for n in gameObjects.get_children():
		n.queue_free()
	
	masterNode.generateMap()
	
func autoTile(pos):
	
	var newTile
	var tileRotation = 0
	
	var oceanDirections = []
	
	#Down, Up, Right, Left
	var tileD = Vector3(pos.x, pos.y, pos.z+1)
	var tileU = Vector3(pos.x, pos.y, pos.z-1)
	var tileR = Vector3(pos.x+1, pos.y, pos.z)
	var tileL = Vector3(pos.x-1, pos.y, pos.z)
	
	#NorthWest, NorthEast, SouthWest, SouthEast
	var tileNW = Vector3(pos.x, pos.y, pos.z+1)
	var tileNE = Vector3(pos.x, pos.y, pos.z-1)
	var tileSW = Vector3(pos.x+1, pos.y, pos.z)
	var tileSE = Vector3(pos.x-1, pos.y, pos.z)

	for i in [tileU, tileD, tileR, tileL]:
		if(waterTile(i)):
			oceanDirections.append(i)
	
	if(oceanDirections.size() == 0):
		return
		
#		for i in [tileNW, tileNE, tileSW, tileSE]:
#			if(waterTile(i)):
#				oceanDirections.append(i)
	
	newTile = oceanDirections.size()+2
	 
	if(oceanDirections.size() == 1):
		
		var direction = oceanDirections[0]
		
		if(pos.z+1 == direction.z):
			tileRotation = 16
		elif(pos.z-1 == direction.z):
			tileRotation = 22
		elif(pos.x+1 == direction.x):
			tileRotation = 10
		
	else:
		var coords = [0, 0]
	
		for i in oceanDirections:
			if(i.x != pos.x):
				if(i.x == pos.x+1):
					coords[0] = 1
				
			if(i.z != pos.z):
				if(i.z == pos.z+1):
					coords[1] = 1
					
		var rotations = {
			[0, 0]: 0,
			[0, 1]: 16,
			[1, 0]: 22,
			[1, 1]: 10
		}
		
		tileRotation = rotations.get(coords)
	
	
	
	tilemap.set_cell_item(pos.x, pos.y, pos.z, newTile, tileRotation)
