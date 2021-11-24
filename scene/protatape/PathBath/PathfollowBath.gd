extends Node2D

signal ok()
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var pathBath = $PathBath
onready var lineBath = $LineBath
onready var drawBath = $DrawBath



func _ready() -> void:
	print(1)
	emit_signal('ok')
	
	$DrawBath.add_child($Plane.draw)
	pass # Replace with function body.

func _process(delta: float) -> void:
	OS.set_window_title("FPS %d" % Engine.get_frames_per_second())


func _on_Plane_path_established(path, line, draw) -> void:
	pathBath.add_child(path)
	lineBath.add_child(line)
	drawBath.add_child(draw)
	
