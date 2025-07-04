extends BaseCharacter
class_name EnemyCharacter

@onready var detect_cliff            : Node2D           = $detect_cliff
@onready var detect_cliff_raycast    : RayCast2D        = $detect_cliff/detect_cliff_raycast
@onready var idle_timer              : Timer            = $timers/idle_timer
@onready var hit_restoring_timer     : Timer            = $timers/hit_restoring_timer
@onready var charge_timer            : Timer            = $timers/charge_timer
@onready var detect_player_area      : Area2D           = $detect_player
@onready var detect_player_shape     : CollisionShape2D = $detect_player/shape

var on_cliff_flag : bool
var target_player : PlayerCharacter
var in_charge : bool = false

func set_body_data() -> void:
	super.set_body_data()
	(detect_player_shape.shape as CircleShape2D).radius = (body_data as EnemyBodyData).view_distance
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	(controller as EnemyController).try_action()
	pass

func attack() -> void:
	if in_charge:
		return
	
	in_charge = true
	charge_timer.start((body_data as EnemyBodyData).charge_time)
	pass

func hit(value : int) -> void:
	if current_condition == CONDITION.DEATH:
		return
	(controller as EnemyController).idle()
	hit_restoring_timer.start((body_data as EnemyBodyData).hit_restoring_time)
	super.hit(value)
	pass

func idle() -> void:
	idle_timer.start((body_data as EnemyBodyData).idle_time)
	(controller as EnemyController).idle()
	pass

func is_on_cliff() -> bool:
	var old_value : bool = on_cliff_flag
	var collision = detect_cliff_raycast.get_collider()
	if collision == null:
		on_cliff_flag = true
	else:
		collision = collision as Node2D
		on_cliff_flag = !collision.is_in_group("platform")
	
	if on_cliff_flag != old_value && on_cliff_flag:
		idle()
	return on_cliff_flag
	pass

func direction_check() -> void:
	super.direction_check()
	detect_cliff.scale.x = -1 if left_direction else 1
	pass

func _on_idle_timer_timeout() -> void:
	(controller as EnemyController).patrol()
	pass # Replace with function body.

func _on_hit_restoring_timer_timeout() -> void:
	check_detect_player()
	if target_player == null:
		(controller as EnemyController).patrol()
	else:
		(controller as EnemyController).attack()
	pass # Replace with function body.


func _on_detect_player_body_entered(body: Node2D) -> void:
	if body is not PlayerCharacter:
		return
	detect_player(body)
	pass # Replace with function body.

func _on_detect_player_body_exited(body: Node2D) -> void:
	if body is not PlayerCharacter:
		return
	if  target_player != null:
		target_player == null
		idle()
	pass # Replace with function body.

func _on_charge_timer_timeout() -> void:
	in_charge = false
	super.attack()
	pass # Replace with function body.

func check_detect_player() -> void:
	var bodies = detect_player_area.get_overlapping_bodies()
	for body in bodies:
		if body is PlayerCharacter:
			detect_player(body)
			return
	pass

func detect_player(checked_character : PlayerCharacter) -> void:
	target_player = checked_character
	(controller as EnemyController).attack()
	#if checked_character.global_position.x < global_position.x && left_direction
	pass

func target_in_attack_range() -> bool:
	var bodies = attack_area.get_overlapping_bodies()
	
	for body in bodies:
		if body is PlayerCharacter:
			return true
	
	return false
	pass
