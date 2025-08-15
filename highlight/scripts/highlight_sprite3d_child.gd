extends Node

@export var shine:PackedScene

var current_instance:Node = null

var current_target:Node = null
func set_highlight(target:Node) -> void:
	if !is_instance_valid(target):
		return

	if is_instance_valid(current_target) and is_instance_valid(current_instance):
		current_target.remove_child(current_instance)
		current_instance = null

	
	current_target = target
	current_instance = shine.instantiate()
	current_target.add_child(current_instance)
