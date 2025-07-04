extends BaseController
class_name EnemyController

enum CONDITIONS {IDLE, PATROL, ATTACK}

var current_condition : CONDITIONS
var current_behavior : Behavior

func set_character(new_character : BaseCharacter) -> void:
	super.set_character(new_character)
	current_behavior = PatrolBehavior.new(new_character)
	current_behavior.set_owner_character(owner_character)
	pass

func try_action() -> void:
	current_behavior.try_action()
	pass

func idle() -> void:
	set_condition(CONDITIONS.IDLE)
	pass

func attack() -> void:
	set_condition(CONDITIONS.ATTACK)
	pass

func patrol() -> void:
	set_condition(CONDITIONS.PATROL)
	pass

func set_condition(new_condition : CONDITIONS) -> void:
	current_condition = new_condition
	#print("set enemy condition %s" % CONDITIONS.keys()[new_condition])
	match current_condition:
		CONDITIONS.IDLE:
			current_behavior = Behavior.new(owner_character)
		CONDITIONS.PATROL:
			current_behavior = PatrolBehavior.new(owner_character)
		CONDITIONS.ATTACK:
			current_behavior = AttackBehavior.new(owner_character)
	pass

func get_movement_vector() -> Vector2:
	return current_behavior.get_movement_vector()
	pass

class Behavior:
	var  owner_character : EnemyCharacter
	
	func _init(owner : EnemyCharacter) -> void:
		set_owner_character(owner)
		pass
	
	func set_owner_character(new_character : EnemyCharacter) -> void:
		owner_character = new_character
		pass
	
	func try_action() -> void:
		pass
	
	func get_movement_vector() -> Vector2:
		return Vector2.ZERO
		pass
	
	func get_current_direction() -> Vector2:
		return Vector2(-1 if owner_character.left_direction else  1, 0)
		pass
	pass

class PatrolBehavior extends Behavior:
	func get_movement_vector() -> Vector2:
		var final_direction = get_current_direction()
		if owner_character.is_on_cliff():
			final_direction = final_direction * -1
		#prints(final_direction, owner_character.is_on_cliff())
		return final_direction
		pass
	pass

class AttackBehavior extends Behavior:
	func get_movement_vector() -> Vector2:
		if owner_character.target_player == null:
			return Vector2.ZERO
		
		var current_direction = get_current_direction()
		var final_direction = Vector2(-1 if owner_character.target_player.global_position.x < owner_character.global_position.x else 1, 0)
		
		if final_direction == current_direction && owner_character.is_on_cliff() || owner_character.target_in_attack_range():
			return Vector2.ZERO
		return final_direction
		pass
	
	func try_action() -> void:
		if(!owner_character.in_charge &&
			owner_character.attack_restored_flag &&
			owner_character.target_player != null &&
			owner_character.target_in_attack_range()):
			owner_character.attack()
		pass
	pass
