extends MarginContainer


func _ready() -> void:
	pass



func _on_EnglishToggle_toggled(button_pressed: bool) -> void:
	if button_pressed:
		TranslationServer.set_locale("en")
	$VBoxContainer/HBoxContainer2/EnglishToggle.disabled = button_pressed
	$VBoxContainer/HBoxContainer2/RussianToggle.set_pressed(!button_pressed)
	Global.save_game("en")


func _on_RussianToggle_toggled(button_pressed: bool) -> void:
	if button_pressed:
		TranslationServer.set_locale("ru")
	$VBoxContainer/HBoxContainer2/RussianToggle.disabled = button_pressed
	$VBoxContainer/HBoxContainer2/EnglishToggle.set_pressed(!button_pressed)
	Global.save_game("ru")


func _on_LanguageSetup_visibility_changed() -> void:
	if Global.load_setup("user://data.sava"):
		TranslationServer.set_locale(Global.lang)
		if Global.lang == "en":
			$VBoxContainer/HBoxContainer2/RussianToggle.set_pressed(false)
			$VBoxContainer/HBoxContainer2/EnglishToggle.set_pressed(true)
		elif Global.lang == "ru":
			$VBoxContainer/HBoxContainer2/RussianToggle.set_pressed(true)
			$VBoxContainer/HBoxContainer2/EnglishToggle.set_pressed(false)
	else:
		TranslationServer.set_locale("en")
		$VBoxContainer/HBoxContainer2/RussianToggle.set_pressed(false)
		$VBoxContainer/HBoxContainer2/EnglishToggle.set_pressed(true)
