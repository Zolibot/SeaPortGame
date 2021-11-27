extends KinematicBody2D

export (int, 0, 1080, 2) var angular_speed_max := 1000
export (int, 0, 2048, 2) var angular_accel_max := 1000 
export (int, 0, 180, 2) var align_tolerance := 2
export (int, 0, 359, 2) var deceleration_radius := 2
export (float, 0, 1000, 40) var player_speed := 600.0 

export (PackedScene) var draw

signal path_established(path,line,draw)
#TODO
signal path_delete(path,line)

export (int) var speed = 100

var velocity = Vector2()

var if_add_child := true

var distance_threshold := 40.0

var face: GSAIFace
var agent := GSAIKinematicBody2DAgent.new(self)

var _accel := GSAITargetAcceleration.new()

var _angular_drag := 0.1
onready var follow_scripts = preload('res://scene/protatape/StearingAiVersion/Follow_target.gd')

onready var path2d:Path2D = Path2D.new()
onready var pathFollow:PathFollow2D = PathFollow2D.new()
onready var line2d:Line2D = Line2D.new()
onready var curve:Curve2D = Curve2D.new()


func _ready() -> void:
	yield(get_parent(),"ok")
	
	draw = draw.instance()
	draw.connect("simlify",self,"_simplify")
	draw.index = 100
	
	
	
	path2d.add_child(pathFollow)
	
	pathFollow.set_loop(false)
	pathFollow.set_lookahead(200) 
	pathFollow.set_position(get_position())
	pathFollow.set_script(follow_scripts)
	
	line2d.antialiased = true
	line2d.set_joint_mode(line2d.LINE_JOINT_ROUND) 
	line2d.set_begin_cap_mode(line2d.LINE_JOINT_ROUND)
	line2d.set_end_cap_mode(line2d.LINE_JOINT_ROUND)
	line2d.set_texture_mode(line2d.LINE_TEXTURE_TILE)
	
	emit_signal("path_established", path2d, line2d, draw)
	if_add_child = false

	
	
	setup(
		pathFollow.agent,
		deg2rad(align_tolerance),
		deg2rad(deceleration_radius),
		deg2rad(angular_accel_max),
		deg2rad(angular_speed_max)
	)
		
	
func setup(
	player_agent: GSAIAgentLocation,
	align_tolerance: float,
	deceleration_radius: float,
	angular_accel_max: float,
	angular_speed_max: float
) -> void:
	face = GSAIFace.new(agent, player_agent)

	face.alignment_tolerance = align_tolerance
	face.deceleration_radius = deceleration_radius

	agent.angular_acceleration_max = angular_accel_max
	agent.angular_speed_max = angular_speed_max
	agent.angular_drag_percentage = _angular_drag

	
	
func _process(delta: float) -> void:
#	pathFollow.set_position(get_global_mouse_position())
	if line2d.get_point_count() > 0:
		if position.distance_to(line2d.get_point_position(0)) < 40:
			line2d.remove_point(0)
	
	
func _physics_process(delta: float) -> void:
	face.calculate_steering(_accel)
	agent._apply_steering(_accel, delta)
	
	pathFollow.offset += speed * delta
	velocity = position.direction_to(pathFollow.get_position()) * speed

#	set_rotation(pathFollow.get_rotation())
	if position.distance_to(pathFollow.get_position()) > 5:
		velocity = move_and_slide(velocity)

func _simplify(active_points) -> void:
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
	
	curve.clear_points()
	
	for x in active_points:
		curve.add_point(x)	
	
	pathFollow.offset = 0
	path2d.set_curve(curve)
	line2d.clear_points()
	line2d.set_points(curve.get_baked_points()) 
	$AnimationPlayer.play("start_speed")
	
	if if_add_child:
		emit_signal("path_established", path2d, line2d)
		if_add_child = false




func _on_Plane_mouse_entered() -> void:
	$AnimationPlayer.play('Chose')
	line2d.clear_points()
	path2d.get_curve().clear_points()
	draw.can_move = true
	if if_add_child:
		emit_signal("path_established", path2d, line2d, draw)
		if_add_child = false


func _on_Plane_mouse_exited() -> void:
	$AnimationPlayer.play('Exit')
	draw.can_move = false
	

func _on_TouchScreenButton_pressed() -> void:
	TouchHelper.index += 1
	print("OK")
	draw.index = TouchHelper.index
	_on_Plane_mouse_entered()


func _on_TouchScreenButton_released() -> void:
	TouchHelper.index -= 1
	draw.index = TouchHelper.index
	_on_Plane_mouse_exited()
