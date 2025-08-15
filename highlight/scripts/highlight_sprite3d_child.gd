extends Node

@export var modes:Array[PackedScene]

var current_instance:Node = null

var current_target:Node = null
var current_mode:int = -1
func set_highlight(target:Node, mode:int) -> void:
	if !is_instance_valid(target):
		return

	if is_instance_valid(current_target) and is_instance_valid(current_instance):
		current_target.remove_child(current_instance)
		current_instance = null

	if !(mode < 0 or mode >= modes.size()):
		current_target = target
		current_instance = modes[mode].instantiate()
		current_target.add_child(current_instance)
