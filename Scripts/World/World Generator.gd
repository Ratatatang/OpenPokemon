extends Node3D

@export var width = 50
@export var height = 50

@onready var shaderProcess = $ShaderProcess/ShaderProcess
@onready var tilemap = $GridMap
@onready var gameObjects = $GameObjects

signal finished_island

var cells = {"Ocean": [], "Plains": [],"Beach": [], "Forest": []}

var biomeData = {"Beach": preload("res://Scripts/BiomeData/Beach.gd"),
				 "Plains": preload("res://Scripts/BiomeData/Plains.gd"),
				 "Ocean": preload("res://Scripts/BiomeData/Ocean.gd"),
				 "Forest": preload("res://Scripts/BiomeData/Forest.gd")}

var playerObj = preload("res://Scenes/World/Entities/Player/Player.tscn")

var temperature = {}
var altitude = {}
var moisture = {}
var noise = FastNoiseLite.new()

var treesMap

var biomeTiles = {"Ocean": 0, "Plains": 1, "Beach": 2, "Forest": 3}
var tileBiomes = {-1: "", 0: "Ocean", 1: "Plains", 2: "Beach", 3: "Forest"}

var globalSpawnPoint = Vector3.ZERO
		
#Generates maps for temp, moisture & altitude used to decide biomes
func _ready():
	randomize()
	#Sets the noise to SmoothOpenSimplexNoise
	noise.noise_type = 1
	
	temperature = generateMap()
	moisture = generateMap()
	await RenderingServer.frame_post_draw
#	altitude = generateMap(180, 5)
	altitude = await generateIsland()

	$ShaderProcess.queue_free()
	setTile(width, height)
	
	MasterInfo.worldMap = getItemMap()
	MasterInfo.worldMapNode = $GridMap
	MasterInfo.worldGenNode = self
	
	generateTrees()
	generateObjects()
	
	while(globalSpawnPoint == Vector3.ZERO):
		var point = Vector3(randf_range(1, 100), 0, randf_range(1, 100))
		if(getBiome(point) == "Beach"):
			globalSpawnPoint = point
	
	globalSpawnPoint = tilemap.map_to_local(Vector3i(globalSpawnPoint.x, 1, globalSpawnPoint.z))
	
	var newPlayer = addPlayer("")

	SignalManager.mapReady.emit()

#Generates 2D noise maps
func generateMap(fre = 0.0049, oct = 9, lun = 1.65, gain = 0.5, str = 0.03):
	noise.noise_type = 1
	noise.frequency = fre
	noise.fractal_octaves = oct
	noise.fractal_lacunarity = lun
	noise.fractal_gain = gain
	noise.fractal_weighted_strength = str
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
	islandNoise.generate_mipmaps = true
	islandNoise.normalize = true
	
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
	
	await islandNoise.changed
	
	
	print(shaderProcess.get_material().get_shader_parameter("island_tex"))
	shaderProcess.get_material().set_shader_parameter("island_tex", islandNoise)
	print(shaderProcess.get_material().get_shader_parameter("island_tex"))
	
	await RenderingServer.frame_post_draw
	
	var island = $ShaderProcess.get_texture().get_image()


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
			
			var xPos = x
			var zPos = z
			
			#Ocean
			if alt < 0.14:
				tilemap.set_cell_item(Vector3i(xPos, 0, zPos), biomeTiles.Ocean)
				cells["Ocean"].append(Vector3(xPos, 0, zPos))
				
			#Beach
			elif between(alt, 0.14, 0.369):
				tilemap.set_cell_item(Vector3i(xPos, 0, zPos), biomeTiles.Beach)
				cells["Beach"].append(Vector3(xPos, 0, zPos))

			#Other Biomes
			elif alt > 0.369:
				
				#Plains
				if between(moist, 0, 1) and between(temp, 0, 0.5):
					tilemap.set_cell_item(Vector3i(xPos, 0, zPos), biomeTiles.Plains)
					cells["Plains"].append(Vector3(xPos, 0, zPos))
				
				#Forest
				elif between(moist, 0, 1) and between(temp, 0, 1):
					tilemap.set_cell_item(Vector3i(xPos, 0, zPos), biomeTiles.Forest)
					cells["Forest"].append(Vector3(xPos, 0, zPos))
					
				"""#Taiga Plains
				elif between(moist, 0, 0.2) and between(temp, 0.2, 0.4):
					tilemap.set_cellv(pos, biomeTiles.TaigaPlains)
				
				#Sulfur
				elif between(moist, 0.4, 0.9) and between(temp, 0.8, 0.9):
					tilemap.set_cellv(pos, biomeTiles.Sulfur)
				
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
					
	var reIndexPlains = []
	var reIndexForest = []
	for tile in cells["Plains"]:
		if(autoTile(tile)):
			reIndexPlains.append(tile)
	
	for tile in cells["Forest"]:
		if(autoTile(tile)):
			reIndexForest.append(tile)
	
	for tile in reIndexPlains:
		cells["Beach"].append(tile)
		cells["Plains"].erase(tile)
	
	for tile in reIndexForest:
		cells["Beach"].append(tile)
		cells["Forest"].erase(tile)
	
	for tile in cells["Beach"]:
		autoTile(tile)
	
	generateTreesMap()

func generateTrees():
	for point in treesMap:
		var pos = Vector3(point.x, 0, point.y)
		var biome = biomeData.get(getBiome(pos)).new()
		
		if(biome.trees != null):
			var tree = load(biome.trees.pick_random())
			
			placeObjectExact(tree, pos)

# Generates objects onto the tiles. trans is the Vector3 for putting the objects in their place and pos is for the biome map
func generateObjects():
	print("--generating objects")
	randomize()
	for x in width:
		for z in height:
			var objectNum = randi_range(0, 100)
			var pos = Vector3(x, 0, z)
				
			if(groundTile(pos)):
				var possibleObjects
				var biome = biomeData.get(getBiome(pos)).new()
				
				if(biome.everyTile != null):
					placeObjectExact(load(biome.everyTile), pos)
				
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
				
				if(possibleObjects != null):
					#Picks a random object from the priority bracket
					var newObject = possibleObjects[randi_range(0, possibleObjects.size()-1)]
					
					placeObject(load(newObject), pos)

func generateTreesMap():
	var square = PackedVector2Array([Vector2(0, 0), Vector2(50, 0), Vector2(50, 50), Vector2(0, 50)])
	treesMap = PoissonDiscSampling.generate_points_for_polygon(square, 0.55, 30)

#Helper func for start < val < end
func between(val, start, end):
	if start <= val and val <= end:
		return true

#Place an object that has a position relative to a different node
# EG: Adding a pokemon that is created inside the nest node
func placeForeignObject(newObject, pos : Vector3, biome = ""):
	placeObject(newObject, to_local(pos), biome)

func placeForeignObjectExact(newObject, pos : Vector3):
	placeObjectExact(newObject, to_local(pos))

func placeObject(objectPath, pos : Vector3, biome = ""):
	var newObject = objectPath.instantiate()
	#Holy Shit Transgender
	var realTrans = tilemap.map_to_local(pos)
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
	pos.y = newObject.position.y
	newObject.global_translate(pos)
	gameObjects.add_child(newObject)

func addPlayer(playerName, pos = globalSpawnPoint):
	var newObject = playerObj.instantiate()
	#var objectTrans = tilemap.map_to_local(Vector3i(0, 0.586, 0))
	newObject.name += playerName
	$Players.add_child(newObject)
	
	newObject.set_spawn(pos, Vector3.ZERO)
	
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

func waterTileGlobal(pos : Vector3):
	if(getBiome(to_local(pos)) == "Ocean"):
		return true
	return false
	
func waterTile(pos : Vector3):
	if(getBiome(pos) ==  "Ocean"):
		return true
	return false
	
func isTile(pos : Vector3, tile):
	if(tilemap.get_cell_item(pos ==  tile)):
		return true
	return false
	
func getBiome(pos: Vector3):
	var cell = tilemap.get_cell_item(pos)
	return tilemap.mesh_library.get_item_name(cell)

func getBiomeGlobal(pos : Vector3):
	pos = tilemap.local_to_map(to_local(pos))
	return getBiome(pos)

func getItemMap():
	var itemMap = {}
	for cell in tilemap.get_used_cells():
		itemMap[cell] = tilemap.get_cell_item(cell)
	
	return itemMap
		
	
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
	
	
#Makes a list of all the other tiles around it
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
		makeBorderTile(adjTiles, pos, "Beach", "Ocean")
	else:
		return correctBeaches(adjTiles, pos)

func correctBeaches(adj, pos):
	for i in adj:
		if(waterTile(i)):
			tilemap.set_cell_item(pos, 2)
			return true
			
	adj.resize(4)
	
	if(getBiome(adj[0]) == "Beach" and getBiome(adj[1]) == "Beach" and getBiome(adj[2]) == "Beach" and getBiome(adj[3]) == "Beach"):
		tilemap.set_cell_item(pos, 2)
		return true
		
	return false

func makeBorderTile(adj, pos, biome, CheckBiome):
	var shapes = []
	
	var image = Image.load_from_file("res://Assets/World/BiomeTiles/Beach.png")
	
	var adjBiomes = []
	for i in 4:
		var tile = adj[i]
		adjBiomes.append(getBiome(tile))
	
	if(adjBiomes[0] == adjBiomes[1] and adjBiomes[0] == adjBiomes[2] and adjBiomes[0] == adjBiomes[3] and adjBiomes[0] != "Beach"):
		tilemap.set_cell_item(pos, biomeTiles.get(adjBiomes[0]))
	
	for i in 4:
		var tile = adj[i]
		if(getBiome(tile) == CheckBiome):
			
			if(pos.x != tile.x):
				if(pos.x+1 == tile.x):
					var border = Image.load_from_file("res://Assets/World/BiomeBorders/OceanBorderH.png")
					drawBorderTile(image, border)
			
				elif(pos.x-1 == tile.x):
					var border = Image.load_from_file("res://Assets/World/BiomeBorders/OceanBorderH.png")
					border.flip_x()
					drawBorderTile(image, border)
			
			elif(pos.z != tile.z):
				if(pos.z+1 == tile.z):
					var border = Image.load_from_file("res://Assets/World/BiomeBorders/OceanBorderV.png")
					drawBorderTile(image, border)
				
				elif(pos.z-1 == tile.z):
					var border = Image.load_from_file("res://Assets/World/BiomeBorders/OceanBorderV.png")
					border.flip_y()
					drawBorderTile(image, border)
	
	var library = tilemap.mesh_library
	#if(library.find_item_by_name(tileName) > -1):
	#	var id = library.find_item_by_name(tileName)
	#	tilemap.set_cell_item(Vector3i(pos), id)
	if(false):
		pass
	else:
		var id = library.get_last_unused_item_id()
		library.create_item(id)
		var mesh = PlaneMesh.new()
		var material = StandardMaterial3D.new()
	
		material.albedo_texture = ImageTexture.create_from_image(image)
		material.texture_filter = material.TEXTURE_FILTER_NEAREST
	
		mesh.size = Vector2(1, 1)
		mesh.material = material
		
		library.set_item_mesh(id, mesh)
		library.set_item_name(id, biome)
		library.set_item_shapes(id, shapes)
			
		tilemap.set_cell_item(Vector3i(pos), id)
	
func drawBorderTile(tile, border):
	for x in 64:
		for z in 64:
			var pixel = border.get_pixel(x, z)
			if(pixel != Color(0, 0, 0, 0)):
				tile.set_pixel(x, z, pixel)
