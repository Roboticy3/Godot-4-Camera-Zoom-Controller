class_name PlayerCameraZoomLimits extends Resource

##	The minimum and maximum zoom expressed in terms of zoom levels.
##	The player camera will not go higher than layers.get_limits(max_zoom) or lower than 
##	layers.get_limits(min_zoom)
@export var min_zoom = 0
@export var max_zoom = 3

@export var layers:ChunkLayerSet

##	Change the zoom limits. Used by CameraNavigator when no chunks can be found
##	down or up after the `zoom_level_changed`.
##	
##	WARNING: DO NOT USE THIS IF THE CURRENT ZOOM LEVEL IS OUT OF THE NEW BOUNDS
##	This function cannot update the zoom in this case, since ChunkNavigator 
##	invokes it on `zoom_level_changed`, which would cause an infinite recursion.
func set_zoom_limits(new_min:int, new_max:int):
	min_zoom = clampi(new_min, 0, layers.layers.size() - 1)
	max_zoom = clampi(new_max, min_zoom, layers.layers.size() - 1)
