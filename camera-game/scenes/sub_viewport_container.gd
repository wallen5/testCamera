extends Control

@export var photo_viewport: SubViewport
@export var photo_camera: Camera3D

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = event.position
			var viewport_size = size
			
			var normalized_pos = mouse_pos / viewport_size
			
			var pixel_pos = normalized_pos * Vector2(
				photo_viewport.size.x,
				photo_viewport.size.y
			)
			
			var ray_origin = photo_camera.project_ray_origin(pixel_pos)
			var ray_direction = photo_camera.project_ray_normal(pixel_pos)
			
			var query = PhysicsRayQueryParameters3D.create(
				ray_origin,
				ray_origin + ray_direction * 100.0
			)
			
			var result = get_viewport().world_3d.direct_space_state.intersect_ray(query)
			
			if result:
				var collider = result.collider
				
				if collider.has_method("interact"):
					collider.interact()
