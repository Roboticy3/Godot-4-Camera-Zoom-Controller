class_name Chunk extends VisibleOnScreenNotifier3D

@export var group:StringName = &"Country"
@export var joint_group:StringName = &"Joint"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group(group)

@export var next:PackedScene
@export var reset_scale := true
@export var reset_rotation := true
@export var reset_zoom := true
func load_chunk(_level:int) -> Node:
	
	if !can_load_chunk():
		return null
	
	var n:Node3D = next.instantiate()
	
	#link this node's transform to the parent, but unlink the visibility.
	var mnt := Node.new()
	add_child(n)
	add_child(mnt)
	mnt.add_to_group(joint_group)
	mnt.process_mode = Node.PROCESS_MODE_ALWAYS
	n.reparent(mnt)
	
	if reset_scale:
		n.scale = Vector3.ONE
	if reset_rotation:
		n.global_rotation = Vector3.ZERO
	if reset_zoom:
		n.global_position.y = 0.0
	
	return n

func can_load_chunk() -> bool:
	if !next:
		printerr("can't load down from ", self, ", no `next` assigned")
		return false
	if !next.can_instantiate():
		printerr("can't load down from ", self, ", `next` has no nodes")
		return false
	
	return true
