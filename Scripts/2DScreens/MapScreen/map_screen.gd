extends Control

@onready var texture = $TextureRect
var map
var markerMap

var colorDict = {
	0 : Color.CORNFLOWER_BLUE,
	1 : Color.SEA_GREEN,
	2 : Color.KHAKI,
	3 : Color.KHAKI,
	4 : Color.KHAKI,
	5 : Color.KHAKI,
	6 : Color.KHAKI
}

func _ready():
	map = Image.create(50, 50, false, 4)
	
	await SignalManager.mapReady
	
	var itemMap = MasterInfo.worldMap
	
	for x in 50:
		for z in 50:
			var pixel = colorDict.get(itemMap[Vector3i(x, 0, z)])
			map.set_pixel(x, z, pixel)
	
	markerMap = map.duplicate()
	
	texture.texture = ImageTexture.create_from_image(map)

func _physics_process(delta):
	if(visible == true):
		var playerPos = MasterInfo.playerPosition
		markerMap = map.duplicate()
		markerMap.set_pixel(floor(playerPos.x), floor(playerPos.z), Color.ORANGE)
		texture.texture = ImageTexture.create_from_image(markerMap)
