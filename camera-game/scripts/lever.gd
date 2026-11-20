extends Node3D

signal state_changed(is_on: bool)

@export var is_on: bool = false

@onready var handle: Node3D = $Handle

func _ready():
	update_visuals()

func interact():
	is_on = !is_on
	update_visuals()
	state_changed.emit(is_on)

func update_visuals():
	var target_angle = -45.0 if is_on else 45.0

	handle.rotation_degrees.z = target_angle
