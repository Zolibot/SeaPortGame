extends Control



func _ready() -> void:
	TranslationServer.set_locale("en")
	pass


func _on_Setup_pressed() -> void:
	$Pop.popup()



