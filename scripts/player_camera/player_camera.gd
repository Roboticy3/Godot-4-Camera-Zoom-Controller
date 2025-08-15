class_name PlayerCamera
extends Camera3D
##	Translate commands from a controller into motions for a camera. Supports both
##	Orthographic and Perspective projections.

##	Emitted when the camera pans or "hovers" horizontally. `to` is a position
##	relative to the parent of the camera in the XZ plane.
signal hover_changed(to:Vector2)
##	Emitted when the camera zooms in or out. Returns a zoom level
signal zoom_changed(to:float)

#I want to reuse this script in other projects, so I don't reference the class
#name here, but the controller for the camera's zoom limits is 
#PlayerCameraLevels
@export var levels:Node = null

#region zooming

func _ready() -> void:
	if is_instance_valid(levels):
		levels.update_zoom(get_zoom())

##	Get/set the current zoom in terms of a float.
func get_zoom() -> float:
	if projection == PROJECTION_ORTHOGONAL:
		return size
	return position.y
func set_zoom(to:float) -> void:
	if projection == PROJECTION_ORTHOGONAL:
		size = to
	position.y = to

##	Set the zoom based on `factor`. The current zoom is multiplied by `factor`,
##	which is meant to be tied to player input like scrolling. The result is 
##	zooming that maintains a consistent speed at high and low values.
##
##	Zooming is done around the cursor position. As a result, the camera may move
##	horizontally, sending a `hover_changed` signal in that case.
##
##	Rare ChatGPT W: 4.0 gave me the idea to zoom around the cursor by measuring 
##	a sort of simulated world position for the mouse cursor before and after the
##	zoom, then subtracting the offset between them from the horizontal position.
func zoom(factor:float) -> void:
	
	var mouse_pos_viewport := get_viewport().get_mouse_position()
	var mouse_pos_world_before := project_position(
		mouse_pos_viewport, 
		get_zoom()
	)
	
	if is_instance_valid(levels):
		set_zoom(
			levels.update_zoom(
				get_zoom() * factor
			)
		)
	else:
		set_zoom(
			get_zoom() * factor
		)
	
	var mouse_pos_world_after := project_position(
		mouse_pos_viewport,
		get_zoom()
	)
	
	var mouse_pos_delta := (mouse_pos_world_after - mouse_pos_world_before)
	position -= mouse_pos_delta
	if !mouse_pos_delta.is_zero_approx():
		hover_changed.emit(
			Vector2(position.x, position.z)
		)
	#print("moust delta ", mouse_pos_delta, ", position ", position, " delta ", mouse_pos_world_after - mouse_pos_world_before, " scale ", (1.0 if factor >= 1.0 else -1.0/get_zoom()))

#endregion

#region panning

##	Based on a mouse motion in screen coordinates, drag the camera horizontally.
##
##	Emits a `hover_changed` signal if `mouse_motion` is not zero.
func lock_cursor_motion(mouse_motion:Vector2) -> void:
	if mouse_motion.is_zero_approx(): return
	
	var mouse_pos_viewport := get_viewport().get_mouse_position()
	var mouse_pos_world_before := project_position(
		mouse_pos_viewport - mouse_motion, 
		get_zoom()
	)
	
	var mouse_pos_world_after := project_position(
		mouse_pos_viewport, 
		get_zoom()
	)
	
	var mouse_pos_delta := mouse_pos_world_after - mouse_pos_world_before
	position -= mouse_pos_delta * Vector3(1,0,1)
	
	hover_changed.emit(
		Vector2(position.x, position.z)
	)

## Manual hover with a motion in the the camera's XZ plane. Emits 
##	`hover_changed`.
func hover(motion:Vector2) -> void:
	if motion.is_zero_approx():
		return
	
	var hover := Vector2(
		position.x, position.z
	)
	
	motion *= get_zoom()
	hover += motion
	
	position.x = hover.x
	position.z = hover.y
	
	hover_changed.emit(
		Vector2(position.x, position.z)
	)

#endregion
