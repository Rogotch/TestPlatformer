extends BaseController
class_name PlayerController

func set_character(new_character : BaseCharacter) -> void:
	super.set_character(new_character)
	InputSystem.jump_pressed.connect(jump_called)
	InputSystem.attack_pressed.connect(attack_called)
	pass

func get_movement_vector() -> Vector2:
	return Vector2(InputSystem.movement_direction, 0)
	pass

func jump_called() -> void:
	owner_character.jump()
	pass

func attack_called() -> void:
	owner_character.attack()
	pass
