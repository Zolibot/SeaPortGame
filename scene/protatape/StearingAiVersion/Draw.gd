extends Node2D



signal simlify(activtePoint)

var dragging := false
var can_move := true
var active_points := []
var is_drawing := false
var is_ := false
var count = 0
var index = 0
#func _ready() -> void:
#	connect('simlify',$Plane,'_simplify')


func _unhandled_input(event: InputEvent) -> void:
	if is_drawing:
		can_move = true
	
	if event is InputEventScreenTouch and can_move:
		if not dragging and event.pressed:
			dragging = true
			active_points.clear()
	   
		if dragging and not event.pressed:
			dragging = false
			is_drawing = false
			can_move = false
			if active_points.size() >= 2:
				emit_signal('simlify', active_points)
			update()

	if event is InputEventScreenDrag and dragging and can_move and index<10:
		active_points.append(TouchHelper.state[index])
		is_drawing = true
		update()




func _draw() -> void:
	if is_drawing and active_points.size() > 0:
		draw_polyline(active_points, Color.skyblue, 5.0,false)
	
#	else:
#		if active_points.size() < 0:
#			draw_circle(active_points.front(), 2, Color.red)
#			draw_circle(active_points.back(), 2, Color.yellow)
#			draw_polyline(active_points, Color.skyblue, 1.0)
