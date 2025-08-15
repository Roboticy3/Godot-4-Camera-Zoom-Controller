class_name ChunkLoader extends Node

##  Chunk detector to find the nearest chunk
@export var detector:ChunkDetector

@export var limits:PlayerCameraZoomLimits
@export var stack:ChunkStack

##	Scene corresponding to the highest zoom level for this navigator
@export var home:PackedScene  :
	set(new_home):
		print("home changed to ", new_home)
		home = new_home
		
##	Where to mount the home in the main scene
@export var home_mnt:=&"Mount"

##	Where to mount layers beneath the home layer.
##	This identifier is not unique. It is used to stop properties being set on 
##		all the nodes in a layer from propogating to lower layers.
@export var joint_group:StringName = &"Joint"

##	The current zoom level
var zoom_level := -1

##	DEBUG readout for which layers are processing. Only bottommost layer should 
##	return true.
##	All other layers should behave as if they are paused. See 
var current_process_states:Array : 
	get():
		return stack.current.map(func (n:Node): return n.is_processing())

func _ready() -> void:
	detector.nearest_chunk_changed.connect(update_zoom_limits.unbind(1))
	update_zoom_limits.call_deferred()

##	When moving down one level, append to `current` the next level down. When
##	moving up, free the last element of `current`. `current` will never become 
##	empty because this method `update_zoom_limits`, which stops `view` from 
##	zooming out past home.
func _on_level_changed(from:int, to:int) -> void:
	if to > stack.home_level:
		printerr("chunk navigator is based on level ", stack.home_level, " and so cannot move to level ", to)
		return
	
	zoom_level = to
	
	var direction = to > from
	
	#`current_upper` may be null, but `current_lower` being null is a problem, 
	#	because that implies there is no level.
	if stack.current.is_empty():
		#load defaults
		load_default()
		await get_tree().process_frame
		var temp := zoom_level
		zoom_level = stack.home_level
		while zoom_level > temp:
			detector.update_nearest_chunk()
			if load_next(zoom_level-1) == null:
				update_zoom_limits()
				break
			zoom_level -= 1
	#going up => shift levels down and free lower levels
	elif direction:
		cut_lowest()
	#going down => shift levels up and DO NOT free higher levels. Hide them instead
	else:
		var result = load_next(zoom_level)
		if !result:
			return

func cut_lowest():
	if !stack.current.is_empty():
		stack.pop()
		set_process_recursive(stack.current[-1], true)

func load_default() -> Node:
	if !home:
		return null
	var n := home.instantiate()
	if get_tree().get_node_count_in_group(home_mnt) > 1:
		printerr("cannot load chunk! Cannot choose between " + str(get_tree().get_node_count_in_group(home_mnt)) + " mount points in " + home_mnt + "!")
		return null
	elif get_tree().get_node_count_in_group(home_mnt) == 0:
		printerr("cannot load chunk! Cannot find mount point in " + home_mnt)
		return null
	get_tree().get_first_node_in_group(home_mnt).add_child.call_deferred(n)
	stack.push(n)
	return n

func load_next(level:int) -> Node:
	if !detector.nearest_chunk: return null
	
	var n = detector.nearest_chunk.load_chunk(level)
	if n:
		stack.push(n)
		set_process_recursive(stack.current[-2], false)
		set_process_recursive(stack.current[-1], true)
		
	return n

#to update the zoom limits, check if there is a valid chunk in the current zoom level
#	and double check that the chunk has a valid load target.
#If there is no valid place to zoom down towards, the limit level should be set to the current level.
#Otherwise, assume there is at least one valid zoom level below.
func update_zoom_limits():
	if detector.nearest_chunk is Chunk and detector.nearest_chunk.can_load_chunk():
		limits.set_zoom_limits(zoom_level-2, stack.home_level)
	
	elif zoom_level == -1:
		limits.set_zoom_limits(stack.home_level - 1, stack.home_level)
	
	else:
		limits.set_zoom_limits(zoom_level-1, stack.home_level)

func set_process_recursive(of:Node, to:bool):
	if to:
		of.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		of.process_mode = Node.PROCESS_MODE_DISABLED
	
	for c in of.get_children():
		if c.is_in_group(joint_group): continue
		set_process_recursive(c, to)
