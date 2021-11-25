extends Node2D








var dragging := false
var active_points := []
var is_drawing := false
var is_ := false
var count = 0

func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass


func _process(delta: float) -> void:
	OS.set_window_title("FPS %d" % Engine.get_frames_per_second())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if not dragging and event.pressed:
			dragging = true
			active_points.clear()
	   
		if dragging and not event.pressed:
			dragging = false
			is_drawing = true
			update()

	if event is InputEventScreenDrag and dragging:
		active_points.append(event.position)
		is_drawing = true
		update()







func _draw() -> void:
	if is_drawing:
		draw_polyline(active_points, Color.skyblue, 5.0,false)
	
