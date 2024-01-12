extends Control

@onready var texture = $TextureRect
var map
var markerMap

var colorDict = {
	"Ocean" : Color.CORNFLOWER_BLUE,
	"Plains" : Color.SEA_GREEN,
	"Beach" : Color.KHAKI,
}

func _ready():
	map = Image.create(50, 50, false, 4)
	
	await SignalManager.mapReady
	
	var itemMap = MasterInfo.worldMap
	var library = MasterInfo.worldMapNode.mesh_library
	
	for x in 50:
		for z in 50:
			pass
			var pixel = colorDict.get(
				library.get_item_name(itemMap[Vector3i(x, 0, z)]))
			map.set_pixel(x, z, pixel)
	
	markerMap = map.duplicate()
	
	texture.texture = ImageTexture.create_from_image(map)

func _physics_process(delta):
	if(visible == true):
		var playerPos = MasterInfo.playerPosition
		markerMap = map.duplicate()
		markerMap.set_pixel(floor(playerPos.x), floor(playerPos.z), Color.ORANGE)
		texture.texture = ImageTexture.create_from_image(markerMap)
