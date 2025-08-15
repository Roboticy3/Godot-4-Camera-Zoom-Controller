extends VisualInstance3D
## Attach to a flat, wide geometry, like a Sprite3D, to supply bounds to a
## PlayerCamera.

@export var zoom_margin := -1.0

func _ready() -> void:
	var camera := get_viewport().get_camera_3d()
	if camera is PlayerCamera:
		camera.hover_changed.connect(update_bounds.bind(camera))

func update_bounds(_hover, camera:PlayerCamera) -> void:
	var aabb := global_transform * get_aabb()
	var rect := Rect2(
		Vector2(aabb.position.x, aabb.position.z),
		Vector2(aabb.size.x, aabb.size.z)
	)
	
	rect.grow(camera.get_zoom() * zoom_margin)
	
	var hover := Vector2(camera.global_position.x, camera.global_position.z)
	var clamp := hover.clamp(rect.position, rect.position + rect.size)
	
	if clamp != hover:
		camera.global_position = Vector3(
			clamp.x, camera.global_position.y, clamp.y
		)
