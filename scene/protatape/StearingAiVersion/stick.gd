extends Area2D

signal stick_to_area()

var lock = true
var connected = false
var ship


func _on_stick_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacle"):
		if not connected:
			area.connect('mouse_exited',self,'_on_stick_area_exited',[Area2D])
			connected = true
		lock = true
		emit_signal('stick_to_area')
		return

	if not area.is_in_group("stick") and not area.is_in_group("obstacle") and ship.my_status[0] == area.get_parent().s:
		position = area.global_position

		if not connected:
			area.connect('mouse_exited',self,'_on_stick_area_exited',[Area2D])
			connected = true
		lock = true
		emit_signal('stick_to_area')


func _on_stick_area_exited(area: Area2D) -> void:
	if area and not area.is_in_group("stick"):
		lock = true
