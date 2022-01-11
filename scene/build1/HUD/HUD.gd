extends CanvasLayer


func _ready() -> void:
	pass

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_on_Pause_pressed()
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_Pause_pressed()



func _on_Pause_pressed() -> void:
#	emit_signal('pause_pressed')
#	get_tree().change_scene("res://UI/UI.tscn")
	$PauseMenu.popup()

