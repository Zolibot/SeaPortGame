extends Control


func _ready() -> void:
	pass


func popup()->void:
	visible = true
	$PopConf.popup()


func _on_Resume_pressed() -> void:
	$PopConf.hide()
	hide()


func _on_Restart_pressed() -> void:
	if not get_tree().reload_current_scene():
		pass


func _on_EndGame_pressed() -> void:
	if not get_tree().change_scene(Global.lavel_menu):
		pass


func _on_MainMenu_pressed() -> void:
	if not get_tree().change_scene(Global.main_menu):
		pass
