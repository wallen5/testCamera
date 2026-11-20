extends CanvasLayer

@export var photo_cam_pos: Node3D
@export var photo_camera: Camera3D

@export var player: CharacterBody3D

var photo_open = false

func _ready():
	open_photo()


func _process(_delta):
	photo_camera.global_transform = photo_cam_pos.global_transform

func _input(event):
	if event.is_action_pressed("takePhoto"):
		if photo_open:
			close_photo()
		else:
			open_photo()


func open_photo():
	photo_open = true
	player.interacting_with_photo = true
	$SubViewportContainer.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_photo():
	photo_open = false
	player.interacting_with_photo = false
	$SubViewportContainer.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
