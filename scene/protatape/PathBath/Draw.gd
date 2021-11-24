extends Node2D



signal simlify(activtePoint)

var can_move := true
var active_points := []
var is_drawing := false
var is_ := false
var count = 0

#func _ready() -> void:
#	connect('simlify',$Plane,'_simplify')


func _unhandled_input(event: InputEvent) -> void:
	if is_drawing:
		can_move = true
	
	if event is InputEventMouseMotion and can_move:
		if is_drawing:
			active_points.append(event.position)
			count+=1
			if count % 10 == 0:
				update()
				count = 0 
	elif event is InputEventMouseButton and can_move:
		if event.pressed and event.button_index == BUTTON_LEFT:
			active_points.clear()
			active_points.append(event.position)
			is_drawing = true
			update()
		elif not event.pressed:
			is_drawing = false
			can_move = false
			if active_points.size() >= 2:
				emit_signal('simlify', active_points)
				active_points.clear()
				


func _draw() -> void:
	if is_drawing:
		draw_polyline(active_points, Color.skyblue, 5.0,false)
		
#	else:
#		if active_points.size() < 0:
#			draw_circle(active_points.front(), 2, Color.red)
#			draw_circle(active_points.back(), 2, Color.yellow)
#			draw_polyline(active_points, Color.skyblue, 1.0)
