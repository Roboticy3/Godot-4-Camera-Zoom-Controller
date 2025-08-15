class_name ChunkFader extends Node

@export var stack:ChunkStack

@export var joint_group:StringName = &"Joint"

@export var base_smoothness := 0.25

##	Fade between two levels.
##	Does nothing if fading down, or fading up from home level.
func _on_fade_changed(from:int, to:int, weight:float) -> void:
	if to < from: return
	
	if stack.current.size() >= 2 and \
		is_instance_valid(stack.current[-2]) and \
		is_instance_valid(stack.current[-1]):
			
		set_recursive("transparency", 1.0 - weight, stack.current[-2])
		set_recursive("transparency", weight, stack.current[-1], pow(base_smoothness * weight, 0.5))
		print("set transparency by ", weight)
func _on_level_changed(from:int, to:int):
	if !stack.current.is_empty() and is_instance_valid(stack.current[-1]):
		set_recursive("transparency", 0.0 if to > from else 1.0, stack.current[-1], 0.0)
		set_recursive("visible", true, stack.current[-1])
		if stack.current.size() >= 2 and to > from:
			set_recursive("visible", true, stack.current[-2], 0.0)
			set_recursive("transparency", 1.0, stack.current[-2], 0.0)
		if stack.current.size() >= 3 and from > to:
			set_recursive("visible", false, stack.current[-3], 0.0)

## Propogate any property through `of`'s children and indirect children.
## Stopping at joints. Used to control transparency and animation speed when
## fading.
##
## Some, but not all properties in Godot work like this out of the box, and for 
## good reason. But not so good a reason that we can't break the rules sometimes.
func set_recursive(prop:String, to:Variant, of:Node, smoothness:float=base_smoothness):
	if of.get(prop) != null:
		var t := create_tween()
		t.tween_property(of, prop, to, smoothness)
	
	for c in of.get_children():
		if c.is_in_group(joint_group): continue
		set_recursive(prop, to, c, smoothness)
