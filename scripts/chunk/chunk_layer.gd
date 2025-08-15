class_name ChunkLayer extends Resource

@export var group:StringName
@export var zoom_limit:float

func _to_string() -> String:
	return "ChunkLayer[{}]".format([group], "{}")
