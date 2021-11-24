extends PathFollow2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	OS.set_window_title("FPS %d" % Engine.get_frames_per_second())
	pass

func _physics_process(delta: float) -> void:
	offset += 200 * delta
