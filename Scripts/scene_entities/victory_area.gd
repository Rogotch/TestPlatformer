@tool
extends Area2D

@onready var shape: CollisionShape2D = $shape
@export var area_shape : Shape2D : set = set_shape

func _ready() -> void:
	set_shape(area_shape)
	pass

func set_shape(new_shape : Shape2D) -> void:
	area_shape = new_shape
	if shape == null:
		return
	shape.shape = new_shape
	pass

func _on_body_entered(body: Node2D) -> void:
	print("entered ", body)
	if body is not PlayerCharacter:
		return
	var victory_tween = create_tween()
	victory_tween.tween_interval(2)
	victory_tween.tween_callback(UiHub.show_victory_win)
	victory_tween.play()
	pass # Replace with function body.
