extends CanvasLayer

const VICTORY_KEY_TITLE = "Победа!"
const VICTORY_KEY_TEXT = "Вы победили!\nХотите сыграть ещё раз?"
const FAIL_KEY_TITLE = "Поражение..."
const FAIL_KEY_TEXT = "Вы проиграли...\nХотите попробовать повторно?"

@onready var dialog_win: ConfirmationDialog = $dialog_win
@onready var health_bar: ProgressBar = $health_bar

func set_health_bar_max_value(max_value : int) -> void:
	health_bar.max_value   = max_value
	health_bar.size.x = 64 * max_value
	pass

func set_health_bar_value(value : int) -> void:
	health_bar.value = value
	pass

func show_victory_win() -> void:
	dialog_win.title = tr(VICTORY_KEY_TITLE)
	dialog_win.dialog_text = tr(VICTORY_KEY_TEXT)
	dialog_win.popup_centered()
	pass

func show_fail_win() -> void:
	dialog_win.title = tr(FAIL_KEY_TITLE)
	dialog_win.dialog_text = tr(FAIL_KEY_TEXT)
	dialog_win.popup_centered()
	pass

func _on_dialog_win_canceled() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_dialog_win_confirmed() -> void:
	dialog_win.hide()
	get_tree().reload_current_scene()
	pass # Replace with function body.
