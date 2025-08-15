## Apply different highlights to one and only one node.
## For example, one node is highlighted when hovered by the mouse, then
## 	given a more visible highlight when the user clicks on it.

extends Node

## Highlights are placed in the `material_overlay` slot as described in
##	https://www.youtube.com/watch?v=CG0TMH8D8kY&t=496s, and are described as 
##	Materials
@export var modes:Array[Material]

## To change the slot materials are placed into, change this.6
@export var target_prop := &"material_overlay"

var current_target:Node = null
var current_mode:int = -1
func set_highlight(target:Node, mode:int) -> void:
	if !is_instance_valid(target):
		return
	
	if is_instance_valid(current_target) and target != current_target:
		current_target.set(target_prop, null)
	
	if !(mode < 0 or mode >= modes.size()):
		current_target = target
		current_target.set(target_prop, modes[mode])
