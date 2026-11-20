
extends CharacterBody3D

@export var speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var gravity: float = 20.0
@export var ground_snap: float = 0.5

@export var aim_pivot: Node3D
@export var camera: Camera3D
@export var photoCam: Camera3D

@export var scroll_sensitivity: float = 3.0
@export var max_aim_angle: float = 60.0

var target_position: Vector3 = Vector3.ZERO
var is_moving: bool = false
var is_aiming: bool = false

var is_holding_left = true

var interacting_with_photo = false



func _ready() -> void:
	target_position = global_position
	floor_snap_length = ground_snap
	floor_max_angle = deg_to_rad(50.0)


func _physics_process(delta: float) -> void:
	
	# Continuously update destination while holding left mouse button
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not is_aiming:
		_get_click_position()
	
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Right-click aiming
	if is_aiming:
		velocity.x = 0.0
		velocity.z = 0.0
		_rotate_toward_mouse(delta)
	# Normal click-to-move
	elif is_moving:
		var current_pos := global_position
		var target_flat := Vector3(
			target_position.x,
			current_pos.y,
			target_position.z
		)
		var distance := Vector2(
			current_pos.x - target_flat.x,
			current_pos.z - target_flat.z
		).length()
		if distance < 0.1:
			is_moving = false
			velocity.x = 0.0
			velocity.z = 0.0
		else:
			var direction := (target_flat - current_pos).normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			var target_angle := atan2(-direction.x, -direction.z)
			rotation.y = lerp_angle(
				rotation.y,
				target_angle,
				rotation_speed * delta
			)
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	#if Input.is_action_just_pressed("takePhoto"):
		#is_moving = false
		#if (photoCam.current):
			#camera.make_current()
		#else:
			#photoCam.make_current()
	if interacting_with_photo:
		velocity.x = 0
		velocity.z = 0
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	# Right click: Aim
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_aiming = event.pressed
			
			if is_aiming:
				is_moving = false
		
		# Scroll wheel: Rotate AimPivot
		if aim_pivot and event.pressed:
		
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_rotate_aim_pivot(-1)
			
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_rotate_aim_pivot(1)


func _rotate_toward_mouse(delta: float) -> void:
	if not camera:
		camera = get_viewport().get_camera_3d()
		if not camera:
			return
			
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_direction := camera.project_ray_normal(mouse_pos)
	# Intersect mouse ray with horizontal plane at player height
	if abs(ray_direction.y) < 0.001:
		return
	var distance := (global_position.y - ray_origin.y) / ray_direction.y
	if distance < 0.0:
		return
	var mouse_world := ray_origin + ray_direction * distance
	# Ignore vertical difference
	var direction := Vector3(
		mouse_world.x - global_position.x,
		0.0,
		mouse_world.z - global_position.z
	)
	if direction.length_squared() < 0.001:
		return
	direction = direction.normalized()
	var target_angle := atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(
		rotation.y,
		target_angle,
		rotation_speed * delta
	)



func _input(event):
	if event.is_action_pressed("interact"):
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			photoCam.global_position,
			photoCam.global_position - photoCam.global_basis.z * 5.0
		)
		var result = space_state.intersect_ray(query)
		if result:
			var collider = result.collider
			print(collider)
			if collider.has_method("interact"):
				print("interacting!")
				collider.interact()


func _rotate_aim_pivot(direction: int) -> void:
	if not aim_pivot:
		return
	var new_angle := aim_pivot.rotation.x + deg_to_rad(
		direction * scroll_sensitivity
	)
	var limit := deg_to_rad(max_aim_angle)
	aim_pivot.rotation.x = clampf(
		new_angle,
		-limit,
		limit
	)


func _get_click_position() -> void:
	
	if interacting_with_photo:
		return
	
	if not camera:
		camera = get_viewport().get_camera_3d()
		if not camera:
			return
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_normal := camera.project_ray_normal(mouse_pos)
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_origin + ray_normal * 1000
	)
	var result := space_state.intersect_ray(query)
	if result:
		target_position = result.position
		is_moving = true
