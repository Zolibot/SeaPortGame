extends Control

export(NodePath) var node_path

onready var PopSelectLang:Popup = get_node(node_path)


func _ready() -> void:
#	TODO global
	if not Global.load_setup("user://data.sava"):
		PopSelectLang.popup()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_on_Exit_pressed()
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_Exit_pressed()

func _process(_delta: float) -> void:
	OS.set_window_title("FPS %d" % Engine.get_frames_per_second())

func _on_Setup_pressed() -> void:
	$Pop.popup()

func _on_Exit_pressed() -> void:
	$ConfirmationDialog.popup()
#	get_tree().quit()

func _on_ButtonBack_pressed() -> void:
	var t = TranslationServer.get_locale()
	Global.save_game(t)
	PopSelectLang.hide()



