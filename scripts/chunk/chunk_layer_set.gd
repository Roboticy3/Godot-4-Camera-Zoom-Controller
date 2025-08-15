class_name ChunkLayerSet extends Resource

@export var layers:Array[ChunkLayer]

func get_group(i:int) -> StringName:
	return layers[i].group

func get_zoom_limit(i:int) -> float:
	return layers[i].zoom_limit

func count() -> int:
	return layers.size()

func _to_string() -> String:
	return "ChunkLayerSet{}".format([str(layers)], "{}")
