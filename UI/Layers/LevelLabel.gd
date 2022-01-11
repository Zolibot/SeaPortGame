extends Control


func _ready() -> void:
	pass

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_on_ButtonBack_pressed()
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_ButtonBack_pressed()

func _on_ButtonBack_pressed() -> void:
	if not get_tree().change_scene("res://UI/UI.tscn"):
		pass
