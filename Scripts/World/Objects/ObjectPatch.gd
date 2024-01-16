class_name ObjectPatch
extends WorldFeature

@export var objectSpawns = {100:[""]}

func _ready():
	if(runReady):
		await SignalManager.objectsBaseReady
		var polygon = $Polygon2D.polygon
		var points = PoissonDiscSampling.generate_points_for_polygon(polygon, 1, 30)
		
		for point in points:
			spawnObjectRandPos("res://Scenes/World/Objects/OakTree.tscn", point.x, point.y, ["Plains"])
