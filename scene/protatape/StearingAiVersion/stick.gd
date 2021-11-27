extends Area2D

signal stick_to_area()

var lock = false
var connected = false

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	
	if not lock:
		position = get_global_mouse_position()
		print(position)



func _on_stick_area_entered(area: Area2D) -> void:
	position = area.position
	if not connected:
		area.connect('mouse_exited',self,'_on_stick_area_exited',[Area2D])
		connected = true
	lock = true
	print("pizda")
	emit_signal('stick_to_area')


func _on_stick_area_exited(area: Area2D) -> void:
	lock = true
