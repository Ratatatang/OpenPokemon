extends Node3D

@export var width = 50
@export var height = 50

@onready var shaderProcess = $ShaderProcess/ShaderProcess
@onready var tilemap = $GridMap
var temperature = {}
var altitude = {}
var moisture = {}
var noise = FastNoiseLite.new()

var globalSpawnPoint = Vector3.ZERO

var biomeTiles = {"Ocean": 0, "Plains": 1, "Beach": 2}
var tileBiomes = {-1: "", 0: "Ocean", 1: "Plains", 6: "Beach"}

var cells = {"Ocean": [], "Plains": [],"Beach": []}

var biomeData = {"Beach": preload("res://Scripts/BiomeData/Beach.gd"),
				 "Plains": preload("res://Scripts/BiomeData/Plains.gd"),
				 "Ocean": preload("res://Scripts/BiomeData/Ocean.gd")}

@onready var playerObj = preload("res://Scenes/Player.tscn")

@onready var masterNode = get_node("/root/Master")
@onready var gameObjects = $GameObjects

signal finished_island
		
#Generates maps for temp, moisture & altitude used to decide biomes
func _ready():
	randomize()
	#Sets the noise to SmoothOpenSimplexNoise
	noise.noise_type = 1
	
	temperature = generateMap(450.0, 5.0)
	moisture = generateMap(450.0, 5.0)
	await RenderingServer.frame_post_draw
#	altitude = generateMap(180, 5)
	altitude = generateIsland()

	shaderProcess.queue_free()
	setTile(width, height)
	
	generateObjects(width, height)
	
	while(globalSpawnPoint == Vector3.ZERO):
		var point = Vector3(randf_range(1, 100), 0, randf_range(1, 100))
		if(getBiome(point) == "Beach"):
			globalSpawnPoint = point
	
	globalSpawnPoint = tilemap.map_to_local(Vector3i(globalSpawnPoint.x, 0.586, globalSpawnPoint.z))
	globalSpawnPoint.y = 0.586
		
	var newPlayer = addPlayer("")
	masterNode.player = newPlayer

#Generates 2D noise maps
func generateMap(fre, oct):
	noise.frequency = fre
	noise.fractal_octaves = oct
	noise.seed = randi()
	var gridName = {}
	
	for x in width:
		for z in height:
			var rand = 2*(abs(noise.get_noise_2d(x, z)))
			gridName[Vector2(x, z)] = rand
	return gridName


#Runs a noise image through the island filter
func generateIsland():
	var gridName = {}
	
	var islandNoise = NoiseTexture2D.new()
	islandNoise.width = 512
	islandNoise.height = 512
	
	#0.0049... is a magic number
	var texNoise = FastNoiseLite.new()
	texNoise.noise_type = 1
	texNoise.frequency = 0.0049
	texNoise.fractal_octaves = 9
	texNoise.fractal_lacunarity = 1.65
	texNoise.fractal_gain = 0.5
	texNoise.fractal_weighted_strength = 0.03
	texNoise.seed = randi()
	
	islandNoise.noise = texNoise
	
	var tex = shaderProcess.material.get_shader_parameter("island_tex")
	tex = islandNoise
	
	var island = shaderProcess.get_texture().get_image()


	for x in width:
		for z in height:
			var rand = (island.get_pixel(x, z))
			gridName[Vector2(x, z)] = rand.r
	
	return gridName
	

#Preliminary, sets every tile to be plains so there are no gaps in the world
func setTile(width, height):
	for x in width:
		for z in height:
			tilemap.set_cell_item(Vector3i(x, 0, z), biomeTiles.Plains)

#Sets the tile in accordance of the moisture, altitude, and temperature of the tile
	for x in width:
		for z in height:
			var alt = altitude[Vector2(x, z)]
			var temp = temperature[Vector2(x, z)]
			var moist = moisture[Vector2(x, z)]
			
			#Ocean
			if alt < 0.16:
				tilemap.set_cell_item(Vector3i(x, 0, z), biomeTiles.Ocean)
				cells["Ocean"].append(Vector3(x, 0, z))
				
			#Beach
			elif between(alt, 0.16, 0.34):
				tilemap.set_cell_item(Vector3i(x, 0, z), biomeTiles.Beach)
				cells["Beach"].append(Vector3(x, 0, z))

			#Other Biomes
			elif alt > 0.34:
				
				#Plains
				#if between(moist, 0.2, 0.5) and between(temp, 0.2, 0.5):
				tilemap.set_cell_item(Vector3i(x, 0, z), biomeTiles.Plains)
				cells["Plains"].append(Vector3(x, 0, z))
					
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
	
	for i in cells["Plains"]:
		autoTile(i)
	for i in cells["Beach"]:
		autoTile(i)

# Generates objects onto the tiles. trans is the Vector3 for putting the objects in their place and pos is for the biome map
func generateObjects(width, height):
	print("--generating objects")
	randomize()
	for x in width:
		for z in height:
			if(randi_range(0, 100) < 70):
				continue
			else:
				var objectNum = randi_range(0, 100)
				var pos = Vector3(x, 0, z)
				
				if(groundTile(pos)):
					var possibleObjects
					var biome = biomeData.get(getBiome(pos)).new()
					var objects = biome.objects
					var keys = objects.keys()
					keys.sort()
					keys.reverse()
					
					#Randomly decides a priority bracket.
					#Each bracket has a chance. if it's equal or greater the
					#Random number, its selected.
					var num = randi_range(1, 100)
					
					for i in keys:
						if i >= num:
							possibleObjects = objects.get(i)
					
					#Picks a random object from the priority bracket
					var newObject = possibleObjects[randi_range(0, possibleObjects.size()-1)]
					
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
	var newObject = load(objectPath).instantiate()
	#Holy Shit Transgender
	var realTrans = tilemap.map_to_local(Vector3i(pos.x, pos.y, pos.z))
	realTrans.x += randf_range(0, 0.3)
	realTrans.z += randf_range(0, 0.3)
	var objectTrans = realTrans
	objectTrans.y = newObject.position.y
	newObject.global_translate(objectTrans)
	
	if(getBiome(tilemap.local_to_map(realTrans)) == biome or biome == ""):
		gameObjects.add_child(newObject)

# Place object, without the random tweaking
func placeObjectExact(objectPath, pos : Vector3):
	var newObject = objectPath.instantiate()
	var objectTrans = tilemap.map_to_local(Vector3i(pos.x, pos.y, pos.z))
	objectTrans.y = newObject.translation.y
	newObject.global_translate(objectTrans)
	gameObjects.add_child(newObject)

func addPlayer(playerName, pos = globalSpawnPoint):
	var newObject = playerObj.instantiate()
	var objectTrans = tilemap.map_to_local(Vector3i(0, 0.586, 0))
	newObject.name += playerName
	$Players.add_child(newObject)
	
#	newObject.set_spawn(pos, Vector3.ZERO)
	
	if(playerName != ""):
		newObject.set_name(playerName)
	
	return newObject

func groundTileGlobal(pos: Vector3):
	pos = tilemap.local_to_map(to_local(pos))
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
	if(tilemap.get_cell_item(Vector3i(pos.x, pos.y, pos.z)) ==  tile):
		return true
	return false
	
func getBiome(pos: Vector3):
	var cell = tilemap.get_cell_item(Vector3i(pos.x, pos.y, pos.z))
	var keys = tileBiomes.keys()
	
	for i in keys:
		if i >= cell:
			return tileBiomes[i]
	
#	return tileBiomes[tilemap.get_cell_item(pos.x, pos.y, pos.z)]
"""
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

puppet func loadChildren(loadables):
	print("--loading children")
	for i in loadables:
		var object = load(i[0]).instantiate()
		object.runReady = false
		object.set_network_master(1)
		object.name = i[1]
		gameObjects.add_child(object)
	
	masterNode.multiplayerReady()

puppet func clearChildren():
	print("--clearing children")
	for n in gameObjects.get_children():
		n.queue_free()
	
	masterNode.generateMap()"""
	
func autoTile(pos):
	
	#Down, Up, Right, Left
	var tileD = Vector3(pos.x, pos.y, pos.z+1)
	var tileU = Vector3(pos.x, pos.y, pos.z-1)
	var tileR = Vector3(pos.x+1, pos.y, pos.z)
	var tileL = Vector3(pos.x-1, pos.y, pos.z)
	
	#NorthWest, NorthEast, SouthWest, SouthEast
	var tileNW = Vector3(pos.x-1, pos.y, pos.z-1)
	var tileNE = Vector3(pos.x+1, pos.y, pos.z-1)
	var tileSW = Vector3(pos.x-1, pos.y, pos.z+1)
	var tileSE = Vector3(pos.x+1, pos.y, pos.z+1)
	
	var adjTiles = [tileD, tileU, tileR, tileL, tileNW, tileNE, tileSW, tileSE]
	
	if(getBiome(pos) == "Beach"):
		beachAutoTile(adjTiles, pos)
	elif(getBiome(pos) == "Plains"):
		plainsAutoTile(adjTiles, pos)

func plainsAutoTile(adj, pos):
	
	for i in adj:
		if(waterTile(i)):
			tilemap.set_cell_item(Vector3i(pos.x, pos.y, pos.z), 2)
			cells["Beach"].append(pos)
			cells["Plains"].erase(pos)
			break

func beachAutoTile(adj, pos):
	adj.resize(4)
	var newTile
	var tileRotation = 0
	var oceanDirections = []
	
	for i in adj:
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
		
	elif(oceanDirections.size() == 2):
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
	
	elif(oceanDirections.size() == 3):
		var direction
		
		for i in oceanDirections:
			if(adj.has(i)):
				adj.erase(i)
		
		direction = adj[0]
# 16, 22, 10
		if(pos.z-1 == direction.z):
			tileRotation = 10
		elif(pos.x+1 == direction.z):
			tileRotation = 16
		elif(pos.x-1 == direction.x):
			tileRotation = 22
	
	tilemap.set_cell_item(Vector3i(pos.x, pos.y, pos.z), newTile, tileRotation)


