extends Node2D

export var width = 600
export var height = 200
onready var tilemap = $TileMap
var temperature = {}
var altitude = {}
var moisture = {}
var biome = {}
var openSimplexNoise = OpenSimplexNoise.new()

var biomeTiles = {"Plains": 0, "Forest": 1, "Swamp": 2, "Taiga": 3, "Tundra": 4, "Jungle": 5, "Savannah": 6, "Desert": 7,  "Sulfur": 8, "TaigaPlains": 9, "Ocean": 10, "Beach": 11,}

#Generates maps for temp, moisture & altitude used to decide biomes
func _ready():
	randomize()
	temperature = generateMap(250, 5)
	moisture = generateMap(250, 5)
	altitude = generateMap(150, 5)
	setTile(width, height)


func generateMap(per, oct):
	openSimplexNoise.seed = randi()
	openSimplexNoise.period = per
	openSimplexNoise.octaves = oct
	var gridName = {}
	
	for x in width:
		for y in height:
			var rand := 2*(abs(openSimplexNoise.get_noise_2d(x, y)))
			gridName[Vector2(x, y)] = rand
	return gridName


func setTile(width, height):
	for x in width:
		for y in height:
			var pos = Vector2(x, y)
			var alt = altitude[pos]
			var temp = temperature[pos]
			var moist = moisture[pos]
			
			#Ocean
			if alt < 0.2:
				tilemap.set_cellv(pos, biomeTiles.Ocean)
				biome[pos] = "Ocean"
			
			#Beach
			elif between(alt, 0.2, 0.27):
				tilemap.set_cellv(pos, biomeTiles.Beach)
				biome[pos] = "Beach"
				
			#Other Biomes
			elif between(alt, 0.27, 1):
				
				#Plains
				#if between(moist, 0.2, 0.5) and between(temp, 0.2, 0.5):
				tilemap.set_cellv(pos, biomeTiles.Plains)
				biome[pos] = "Plains"
					
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
#					biome[pos] = "Beach"
					
#Helper func for start < val < end
func between(val, start, end):
	if start <= val and val <= end:
		return true
		
#func _input(event):
#	if event.is_action_pressed("ui_accept"):
#		get_tree().reload_current_scene()
