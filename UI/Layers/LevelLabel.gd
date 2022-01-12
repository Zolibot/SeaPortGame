extends Control


var levelTile = preload('res://UI/Layers/LevelTile.tscn')
var level_path = "res://scene/build1/level/"

onready var grid = $MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/GridContainer

func _ready() -> void:

	var directory = Directory.new()
	if directory.open(level_path) == OK:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				#print("Found directory: " + file_name)
				pass
			else:
				#print("Found file: " + file_name)
				if file_name.find(".tscn") > 0:
					print(file_name)
					_addLevelToGrid(level_path + file_name , file_name)
			file_name = directory.get_next()
	else:
		print("An error occurred when trying to access the path.")

func _addLevelToGrid(level, name)->void:
	var level_t = levelTile.instance()
	level_t.level_path = level
	level_t.set_name(name)
	grid.add_child(level_t)
	print("add child level_t: ", level)
	pass

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_on_ButtonBack_pressed()
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_ButtonBack_pressed()

func _on_ButtonBack_pressed() -> void:
	if not get_tree().change_scene(Global.main_menu):
		pass
