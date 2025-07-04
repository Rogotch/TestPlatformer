extends Resource
class_name BodyData

signal died

@export var max_hp          : int
@export var attack          : int
@export var speed           : float
@export var jump_cooldown   : float
@export var jump_strength   : float
@export var attack_cooldown : float

var hp : int

var owner_character : BaseCharacter
var died_flag : bool = false

func set_character(new_character : BaseCharacter) -> void:
	owner_character = new_character
	died.connect(owner_character.death)
	hp = max_hp
	pass

func hit(value : int) -> void:
	print("hitted, old hp = %s, max_hp = %s, new hp = %s" % [hp, max_hp, hp - value])
	hp -= value
	death_check()
	pass

func death_check() -> void:
	if hp <= 0:
		death()
	pass

func death() -> void:
	died_flag = true
	died.emit()
	pass

func is_alive() -> bool:
	return !died_flag
	pass
