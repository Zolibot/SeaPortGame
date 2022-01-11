extends Node2D


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	$ShadowHull.global_position = global_position + Vector2(-7,7)
	$ShadowSuperstruche.global_position = $Superstruche.global_position + Vector2(-7,7)
	$ShadowTube.global_position = $Tube.global_position + Vector2(-7,7)
	$ShadowRadar.global_position = $Radar.global_position + Vector2(-3,3)
	$ShadowRadar.rotation = $Radar.rotation
