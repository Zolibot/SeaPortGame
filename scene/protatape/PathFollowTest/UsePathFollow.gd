extends Node2D

signal path_established(points)


var active_points := []
var is_drawing := false
var is_ := false
var distance_threshold := 40.0
var count = 0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if is_drawing:
			active_points.append(event.position)
			count+=1
			if count % 10 == 0:
				update()
				count = 0


	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			active_points.clear()
			active_points.append(event.position)
			is_drawing = true
			update()
		elif not event.pressed:
			is_drawing = false
			if active_points.size() >= 2:
				_simplify()


func _draw() -> void:
	if is_drawing:
		draw_polyline(active_points, Color.skyblue, 5.0,false)
#	else:
#		if active_points.size() < 0:
#			draw_circle(active_points.front(), 2, Color.red)
#			draw_circle(active_points.back(), 2, Color.yellow)
#			draw_polyline(active_points, Color.skyblue, 1.0)


func _simplify() -> void:
	var first: Vector2 = active_points.front()
	var last: Vector2 = active_points.back()
	var key := first
	var simplified_path := [first]
	for i in range(1, active_points.size()):
		var point: Vector2 = active_points[i]
		var distance := point.distance_to(key)
		if distance > distance_threshold:
			key = point
			simplified_path.append(key)
	active_points = simplified_path
	if active_points.back() != last:
		active_points.append(last)
	update()
	var curve:Curve2D = Curve2D.new()

	for x in active_points:

		curve.add_point(x)

	$Path2D.set_curve(curve)
	$Path2D/PathFollow2D.offset = 0
	$Line2D.clear_points()
	$Line2D.set_points(curve.get_baked_points())
	emit_signal("path_established", active_points)
