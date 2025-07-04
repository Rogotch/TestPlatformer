extends CharacterBody2D
class_name BaseCharacter

enum CONDITION {IDLE, MOVE, ATTACK, HIT, DEATH, JUMP}

@onready var sprite                  : Sprite2D            = $sprite
@onready var shape                   : CollisionShape2D    = $shape
@onready var jump_cooldown           : Timer               = $timers/jump_cooldown
@onready var attack_cooldown         : Timer               = $timers/attack_cooldown
@onready var anim_player             : AnimationPlayer     = $anim_player
@onready var anim_tree               : AnimationTree       = $anim_tree
@onready var weapon_anim_tree        : AnimationTree       = $sprite/hand_node/hand_position/hand/weapon_anim_tree
@onready var weapon_anim_player      : AnimationPlayer     = $sprite/hand_node/hand_position/hand/weapon_anim_player
@onready var on_the_ground_raycast   : RayCast2D           = $on_the_ground_raycast
@onready var hand_node               : Node2D              = $sprite/hand_node
@onready var attack_area             : Area2D              = $sprite/hand_node/attack_area

@export var controller : BaseController
@export var body_data  : BodyData

var   jump_restored_flag : bool = true
var attack_restored_flag : bool = true
var on_the_ground_flag   : bool

var left_direction : bool
var current_condition : CONDITION = -1
var playback        : AnimationNodeStateMachinePlayback
var weapon_playback : AnimationNodeStateMachinePlayback

var        anim_controller : AnimTreeController
var weapon_anim_controller : AnimTreeController

func _ready() -> void:
	anim_controller        = AnimTreeController.get_new(anim_tree)
	weapon_anim_controller = AnimTreeController.get_new(weapon_anim_tree)
	set_controller()
	set_body_data()
	set_condition(CONDITION.JUMP)
	weapon_anim_controller.show_animation("idle")
	pass

func set_body_data() -> void:
	body_data = body_data.duplicate()
	body_data.set_character(self)
	pass

func set_controller() -> void:
	controller = controller.duplicate()
	controller.set_character(self)
	pass

func _physics_process(delta: float) -> void:
	#velocity = controller.get_movement_vector() * SPEED
	velocity = velocity.lerp(get_velocity_vector(), 0.2)
	move_and_slide()
	on_the_ground_check()
	direction_check()
	if on_the_ground_flag && current_condition != CONDITION.DEATH:
		set_condition(CONDITION.MOVE if abs(velocity.x) > 0 else CONDITION.IDLE)
	pass

func direction_check() -> void:
	if velocity.x == 0:
		return
	var old_value : bool = left_direction
	left_direction = velocity.x < 0
	sprite.flip_h = left_direction
	hand_node.scale.x = -1 if left_direction else 1
	pass

func on_the_ground_check() -> void:
	var ground_collision = false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider : Node2D = collision.get_collider()
		if collider.is_in_group("platform"):
			ground_collision = true
			break
	if !ground_collision:
		on_the_ground_flag = false
	else:
		var raycast_collider = on_the_ground_raycast.get_collider()
		if raycast_collider != null:
			on_the_ground_flag = raycast_collider.is_in_group("platform")
	if !on_the_ground_flag && velocity.y > 0:
		anim_controller.show_animation("jump_down")
	pass

func get_velocity_vector() -> Vector2:
	var x : float = controller.get_movement_vector().x * body_data.speed if current_condition != CONDITION.DEATH else 0
	var y : float = clampf(velocity.y + 0.98 * Config.gravitation, -2000, 1000)
	return Vector2(x, y)
	pass

func jump() -> void:
	if !jump_restored_flag || !on_the_ground_flag || current_condition == CONDITION.DEATH:
		return
	velocity.y = -body_data.jump_strength
	jump_restored_flag = false
	jump_cooldown.start(body_data.jump_cooldown)
	set_condition(CONDITION.JUMP)
	pass

func attack() -> void:
	if !attack_restored_flag || current_condition == CONDITION.DEATH:
		return
	attack_restored_flag = false
	attack_cooldown.start(body_data.attack_cooldown)
	for body in attack_area.get_overlapping_bodies():
		if body is BaseCharacter and body != self:
			body.hit(body_data.attack)
	set_condition(CONDITION.ATTACK)
	pass

func hit(value : int) -> void:
	if current_condition == CONDITION.DEATH:
		return
	set_condition(CONDITION.HIT)
	body_data.hit(value)
	pass

func death() -> void:
	z_index = -1
	#set_physics_process(false)
	set_condition(CONDITION.DEATH)
	pass

func set_condition(new_condition : CONDITION) -> void:
	if new_condition == current_condition:
		return
	#print("set condition %s in %s" % [CONDITION.keys()[new_condition], name])
	current_condition = new_condition
	
	match new_condition:
		CONDITION.IDLE:
			anim_controller.show_animation("idle")
		CONDITION.MOVE:
			anim_controller.show_animation("move")
		CONDITION.JUMP:
			anim_controller.show_animation("jump_start")
		CONDITION.ATTACK:
			weapon_anim_controller.show_animation("attack")
		CONDITION.HIT:
			anim_controller.show_animation("hit", true)
		CONDITION.DEATH:
			anim_controller.show_animation("death")
			weapon_anim_controller.show_animation("death")
	pass

func _on_jump_cooldown_timeout() -> void:
	jump_restored_flag = true
	pass # Replace with function body.

func _on_attack_cooldown_timeout() -> void:
	attack_restored_flag = true
	pass # Replace with function body.


class AnimTreeController:
	var playback : AnimationNodeStateMachinePlayback
	
	static func get_new(animation_tree_node : AnimationTree) -> AnimTreeController:
		var new_atc = AnimTreeController.new()
		new_atc.playback = animation_tree_node.get("parameters/playback")
		return new_atc
		pass
		
	func show_animation(anim_name : String, hard_run : bool = false) -> void:
		if hard_run:
			playback.stop()
			playback.start(anim_name)
		else:
			playback.travel(anim_name)
		pass
	pass
	
	
