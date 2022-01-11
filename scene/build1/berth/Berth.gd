tool
extends StaticBody2D


export(String,"FUEL","REPAIR","CARGO") var s


export(String,FILE) var fuel
export(String,FILE) var cargo
export(String,FILE) var repair

onready var status:Dictionary= { "FUEL":fuel, "CARGO":cargo, "REPAIR":repair}


func _ready() -> void:
	$labelSprite.texture = load(status[s])
	$labelSprite.global_rotation_degrees = 0
	$berthSprite2.global_position = $berthSprite.global_position + Vector2(-7, 7)


func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("ship") and body.my_status[0] == s:
		body.berth = self
		body.change_state(body.MOORING, 0.1)
		body.line2d.clear_points()

func _on_Area2D_body_exited(_body: Node) -> void:
	pass # Replace with function body.
