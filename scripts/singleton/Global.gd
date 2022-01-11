extends Node

var lang

var main_menu = "res://UI/UI.tscn"
var lavel_menu = "res://UI/Layers/LevelLabel.tscn"

func _ready() -> void:


	pass




func save_game(data):
	var file:File = File.new()
	if not file.open("user://data.sava",File.WRITE):
		lang = data
		file.store_var(data)
		file.close()


func load_setup(path)->bool:
	var file:File = File.new()
	if not file.file_exists(path):
		return false
	if not file.open(path,File.READ):
		lang = file.get_var()
		TranslationServer.set_locale(lang)
		file.close()
	return true
