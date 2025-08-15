class_name ChunkNavigator extends Node3D
##	Turn a PlayerCamera's movements into events that load and unload chunks to
##	fill in the zoom level.
##
##	The chunk loaded while zooming in depends on the `nearest_chunk` property,
##	a loader with a position in space, and the `chunk_layers` array:
##
##	At each `zoom_level`, `chunk_layers` defines a group which a set of 
##	Chunks should belong to. This script then continuously updates 
##	`nearest_chunk` to be the chunk physically closest to `view`. Each 
##	Chunk defines a chunk to load when zoomed in on. When the view zooms
##	in, the chunk is loaded and appended onto `current`.

@export var loader:ChunkLoader
@export var detector:ChunkDetector
@export var fader:ChunkFader

##	The player camera
@export var view:PlayerCamera

## Set to respond to the view's behavior
func _ready() -> void:
	view.levels.level_changed.connect(loader._on_level_changed)

	view.levels.level_changed.connect(fader._on_level_changed)
	view.levels.fade_changed.connect(fader._on_fade_changed)

	view.levels.level_changed.connect(detector._on_level_changed)
	view.hover_changed.connect(detector._on_hover_changed)
