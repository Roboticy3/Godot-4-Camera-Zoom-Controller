extends PlayerCameraController
## Version of PlayerCameraController that does not require any keybinds to be
## set up.

func _unhandled_input(event: InputEvent) -> void:
	if  event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		view.lock_cursor_motion(event.screen_relative)
	
	if !event.is_pressed():
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			view.zoom(1.0 / zoom_factor)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			view.zoom(zoom_factor)
	
	if event is InputEventKey and Input.is_key_pressed(KEY_CTRL):
		if event.keycode == KEY_UP:
			view.zoom(1.0 / fast_zoom_factor)
		elif event.keycode == KEY_DOWN:
			view.zoom(fast_zoom_factor)
	
	

func _process(delta: float) -> void:
	
	var motion := \
		(Vector2.UP if Input.is_key_pressed(KEY_UP) else Vector2.ZERO) + \
		(Vector2.LEFT if Input.is_key_pressed(KEY_LEFT) else Vector2.ZERO) + \
		(Vector2.DOWN if Input.is_key_pressed(KEY_DOWN) else Vector2.ZERO) + \
		(Vector2.RIGHT if Input.is_key_pressed(KEY_RIGHT) else Vector2.ZERO)
		
	if !motion.is_zero_approx(): 
		view.hover(motion * speed * delta)
