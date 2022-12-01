extends Spatial

export var width = 300
export var height = 300
onready var tilemap = $GridMap
var temperature = {}
var altitude = {}
var moisture = {}
var openSimplexNoise = OpenSimplexNoise.new()

var biomeTiles = {"Plains": 0, "Ocean": 1, "Beach": 2}
var tileBiomes = {0: "Plains", 1: "Ocean", 2: "Beach"}

onready var nest = load("res://OpenWorld/WildPokemon/Nest.tscn")

#Generates maps for temp, moisture & altitude used to decide biomes
func _ready():
	randomize()
	temperature = generateMap(450, 5)
	moisture = generateMap(450, 5)
	altitude = generateMap(250, 5)
	setTile(width, height)

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

"""const WIDTH := 1024
const HEIGHT := 1024
const SCALE := 1

onready var island := $island as TextureRect

var noise : OpenSimplexNoise = OpenSimplexNoise.new()

func generateMap(per, oct):
	randomize()
	noise.seed = randi()
	noise.octaves = 9
	noise.period = 192
	noise.persistence = 0.6
	var imgt := ImageTexture.new()
	imgt.create_from_image(noise.get_image(island.get_rect().size.x * SCALE, island.get_rect().size.y * SCALE))
	var mat := island.get_material()
	mat.set_shader_param("island_tex", imgt)"""
	

#Sets the tile in accordance of the moisture, altitude, and temperature of the tile
func setTile(width, height):
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
			elif between(alt, 0.2, 0.27):
				tilemap.set_cell_item(x, 0, z, biomeTiles.Beach)

			#Other Biomes
			elif between(alt, 0.27, 1):
				
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
				
#				if biome[Vector2(pos.x-1, pos.y-1)] == "Ocean" or biome[Vector2(pos.x-1, pos.y+1)] == "Ocean" or biome[Vector2(pos.x+1, pos.y-1)] == "Ocean" or biome[Vector2(pos.x+1, pos.y+1)] == "Ocean":
#					tilemap.set_cellv(pos, biomeTiles.Beach)
	generateObjects(width, height)

# Generates objects onto the tiles. trans is the Vector3 for putting the objects in their place and pos is for the biome map
func generateObjects(width, height):
	randomize()
	for x in width:
		for z in height:
			var seedNum = round(rand_range(0, 100))
			
			if(seedNum < 70):
				continue
			
			#Holy shit transgender
			var pos = Vector3(x, 0, z)
			var trans = Vector3(x, 0.931, z)
				
			if(tileBiomes[getBiome(pos)] == "Beach"):
				if(seedNum > 90):
					var newObject = nest.instance()
					newObject.translate(trans)
					add_child(newObject)

#Helper func for start < val < end
func between(val, start, end):
	if start <= val and val <= end:
		return true
		
#func _input(event):
#	if event.is_action_pressed("ui_accept"):
#		get_tree().reload_current_scene()

func groundTile(pos : Vector3):
	if(tilemap.get_cell_item(pos.x, pos.y, pos.z) !=  "Ocean"):
		return true
	return false
	
func waterTile(pos : Vector3):
	if(tilemap.get_cell_item(pos.x, pos.y, pos.z) ==  "Ocean"):
		return true
	return false
	
func isTile(pos : Vector3, tile):
	if(tilemap.get_cell_item(pos.x, pos.y, pos.z) ==  tile):
		return true
	return false
	
func getBiome(pos: Vector3):
	return tilemap.get_cell_item(pos.x, pos.y, pos.z)
