extends Control


func _ready() -> void:
	pass


func popup()->void:
	visible = true
	$PopConf.popup()


func _on_No_pressed() -> void:
	hide()
	$PopConf.hide()


func _on_Yes_pressed() -> void:
	get_tree().quit()
