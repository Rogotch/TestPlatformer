extends Node

signal jump_pressed
signal attack_pressed

var movement_direction : float

func _physics_process(delta: float) -> void:
	movement_direction = Input.get_axis(&"move_left", &"move_right")
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"jump") || Input.is_action_just_pressed(&"move_up"):
		jump_pressed.emit()
	if Input.is_action_just_pressed(&"attack"):
		attack_pressed.emit()
	pass
