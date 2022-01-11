extends Node2D

signal ok()

onready var pathBath = $PathBath
onready var lineBath = $LineBath
onready var drawBath = $DrawBath

func _ready() -> void:
	emit_signal('ok')
	#_get_viewport_png()



func _process(_delta: float) -> void:
	OS.set_window_title("FPS %d" % Engine.get_frames_per_second())



func _get_viewport_png()->void:
	yield(get_tree(),'idle_frame')
	yield(get_tree(),'idle_frame')
	var viewport:Viewport = get_viewport()
	viewport.transparent_bg = true
	yield(get_tree(),'idle_frame')
	yield(get_tree(),'idle_frame')
	var image:Image = viewport.get_texture().get_data()

	image.flip_y()
	if not image.save_png("res://1234.png"):
		pass
	viewport.transparent_bg = false
	print("save ok")

func _on_Ship_path_established(path, line, draw) -> void:
	pathBath.add_child(path)
	lineBath.add_child(line)
	drawBath.add_child(draw)


