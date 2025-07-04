extends Resource
class_name BaseController

var owner_character : BaseCharacter

func set_character(new_character : BaseCharacter) -> void:
	owner_character = new_character
	pass

func get_movement_vector() -> Vector2:
	return Vector2.ZERO
	pass
