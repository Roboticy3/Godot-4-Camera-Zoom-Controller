class_name ChunkStack extends Resource

##	The corresponding zoom level of this position
@export var home_level:int = 3

##	Store a path from the home scene. Should always contain the home at index 0.
##	The zoom level of any element `i` in the array is then `home_level - i`
##	The current scene being viewed is always `current[-1]`
var current:Array[Node3D]

func pop():
	var c = current.pop_back()
	if is_instance_valid(c):
		c.queue_free()

func push(n:Node3D):
	current.append(n)
