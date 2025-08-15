class_name ChunkDetector extends Node3D

@export var limits:PlayerCameraZoomLimits

var nearest_chunk:Chunk = null :
	set(new_nearest_chunk):
		if nearest_chunk == new_nearest_chunk:
			return
		nearest_chunk = new_nearest_chunk
		nearest_chunk_changed.emit(nearest_chunk)

signal nearest_chunk_changed(nearest_chunk:Chunk)

func update_nearest_chunk():
	var candidate:Chunk = null
	var min_ord := INF
	
	for c in get_chunks():
		if c is Chunk and c.is_on_screen():
			var ord := global_position.distance_squared_to(c.global_position)
			if ord < min_ord:
				candidate = c
				min_ord = ord
	
	nearest_chunk = candidate

func get_chunks():
	var chunk_layer := limits.layers.get_group(zoom_level)
	return get_tree().get_nodes_in_group(chunk_layer)

func _on_hover_changed(_hover:Vector2):
	# Update the nearest chunk based on the hover position
	update_nearest_chunk()

var zoom_level:int = -1
func _on_level_changed(_from:int, to:int):
	zoom_level = to
	update_nearest_chunk()
