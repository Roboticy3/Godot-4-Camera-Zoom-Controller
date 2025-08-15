class_name PlayerCameraLevels extends Node
##	Emits events when the a PlayerCamera zoom passes certain thresholds relative to
##	`zoom_levels`, to tell a Chunk Navigator to load the next level down or up,
##	and to cause smooth fades between them.

##	Emitted when the zoom level changes. `direction` is `true` when going up,
##	and `false` when going down.
signal level_changed(from:int, to:int)
##	Emitted when the fade level changes. When moving between levels `from` and
##	`to`. It is up to the reciever how to interpret `weight`, a scale from 0.0
##	to 1.0 where 0.0 means "100% `from` and 0% `to`" and 1.0 means `100% `to` 
##	and 0% `from`". A weight of 1.0 will actually never be sent, since it should
##	be equivalent to `level_changed.emit(from, to)`.
signal fade_changed(from:int, to:int, weight:float)

##	Definition of regions for each zoom level
@export var limits:PlayerCameraZoomLimits

##	`zoom_level[i] * fade` = the point where the scene should start to fade from
##	level `i-1` to `i`. From there, the levels are faded between smoothly.
@export var fade := 0.25

##	Get the current zoom level in terms of a level.
##	Returns -1 if no zoom level was high enough to contain the current
##	floating-point zoom.
func get_zoom_level(at:float) -> int:
	for i in limits.layers.count():
		if limits.layers.get_zoom_limit(i) > at:
			return i
	return -1

##	The zoom level recorded on the last `update_zoom` call.
var last_zoom_level := -1
##	The fade weight recorded on the last `update_zoom` call.
var last_fade_weight:float = 1.0
##	Update `last_zoom_level`, `last_fade_weight`, and emit `level_changed` and
##	`fade_changed` signals.
func update_zoom(to:float) -> float:
	
	to = clampf(
		to,
		limits.layers.get_zoom_limit(limits.min_zoom),
		limits.layers.get_zoom_limit(limits.max_zoom),
	)
	
	#assuming zoom levels are ordered, find the lowest level exceeding 
	#	position.y
	var i = get_zoom_level(to)
	#if new zoom level is -1, we've zoomed too far out. `zoom` will handle
	#	limiting the actual camera position, so just don't emit any loading
	#	signals.
	if i == -1:
		return to
	if i != last_zoom_level:
		last_fade_weight = 1.0
		fade_changed.emit(
			i,
			i+1,
			last_fade_weight
		)
		level_changed.emit(last_zoom_level, i)
		last_zoom_level = i

	#if position.y is in the fade region for this
	var fade_end := limits.layers.get_zoom_limit(last_zoom_level)
	var fade_start := fade_end * fade
	if to >= fade_start:
		last_fade_weight = (to - fade_start) / (fade_end - fade_start)
		fade_changed.emit(
			last_zoom_level, 
			last_zoom_level+1, 
			last_fade_weight
		)
	else:
		last_fade_weight = 0.0
		fade_changed.emit(
			last_zoom_level,
			last_zoom_level+1,
			last_fade_weight
		)
	
	return to
