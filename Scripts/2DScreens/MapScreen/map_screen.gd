extends Control

@onready var texture = $TextureRect

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
	var map = Image.create(50, 50, false, 4)
	
	await SignalManager.mapReady
	
	var itemMap = MasterInfo.worldMap
	
	for x in 50:
		for z in 50:
			var pixel = colorDict.get(itemMap[Vector3i(x, 0, z)])
			map.set_pixel(x, z, pixel)
	
	texture.texture = ImageTexture.create_from_image(map)
