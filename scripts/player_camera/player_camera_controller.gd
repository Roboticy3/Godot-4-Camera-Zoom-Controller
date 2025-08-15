class_name PlayerCameraController extends Node

@export var view:PlayerCamera

@export var zoom_factor := 1.2
@export var speed := 5.0

@export var fast_zoom_factor := 10.0

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("z_in"):
		view.zoom(1.0 / zoom_factor)
	elif event.is_action_pressed("z_out"):
		view.zoom(zoom_factor)
	
	if event.is_pressed() and Input.is_action_pressed("d_ctrl"):
		if event.is_action("ui_up"):
			view.zoom(1.0 / fast_zoom_factor)
		elif event.is_action("ui_down"):
			view.zoom(fast_zoom_factor)
	
	if Input.is_action_pressed("m_drag") and event is InputEventMouseMotion:
		view.lock_cursor_motion(event.screen_relative)

func _process(delta: float) -> void:
	var motion := Input.get_vector("m_left", "m_right", "m_up", "m_down")
	if !motion.is_zero_approx(): 
		view.hover(motion * speed * delta)
