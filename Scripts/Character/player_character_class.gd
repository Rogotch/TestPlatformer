extends BaseCharacter
class_name PlayerCharacter

func set_body_data() -> void:
	super.set_body_data()
	UiHub.set_health_bar_max_value(body_data.max_hp)
	UiHub.set_health_bar_value(body_data.hp)
	pass

func hit(value : int) -> void:
	super.hit(value)
	UiHub.set_health_bar_value(body_data.hp)
	pass

func death() -> void:
	super.death()
	var death_tween = create_tween()
	death_tween.tween_interval(2)
	death_tween.tween_callback(UiHub.show_fail_win)
	death_tween.play()
	pass
