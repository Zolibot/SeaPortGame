extends Sprite




onready var pathFollow:PathFollow2D = $".."


func _process(delta):
	pathFollow.offset += 200 * delta
	
