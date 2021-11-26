extends PathFollow2D



onready var agent := GSAIAgentLocation.new()

func _ready() -> void:
	agent.position = Vector3(300, 300, 0)

func _physics_process(_delta: float) -> void:
	agent.position = Vector3(position.x, position.y, 0)
