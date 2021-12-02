extends KinematicBody2D

signal path_established(path,line,draw)
signal path_delete(path,line)

enum {IDLE, RUN, GAIN_SPEED, CLEAN_UP_SPEED, MOORING, UNMOORING, COLLISION, MANEUVER}

export (int, 0, 1080, 2) var angular_speed_max := 1000
export (int, 0, 2048, 2) var angular_accel_max := 1500 
export (int, 0, 180, 2) var align_tolerance := 10
export (int, 0, 359, 2) var deceleration_radius := 10
export (float, 0, 1000, 40) var player_speed := 900.0 

export (PackedScene) var draw
export (int) var speed = 100

var state
var velocity = Vector2()
var if_add_child := true
var distance_threshold := 20.0
var dist_clear_point := 20.0
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
	
	state = IDLE
	
	draw = draw.instance()
	draw.connect("simlify",self,"_simplify")
	# Crutch for multitouch
	draw.index = 100
	
	path2d.add_child(pathFollow)
	
	pathFollow.set_loop(false)
	pathFollow.set_lookahead(0) 
	pathFollow.set_position(get_position()+Vector2(2,2))
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
	if line2d.get_point_count() > 0:
		var _index = 0
		for x in line2d.get_points():
			if position.distance_to(line2d.get_point_position(_index)) < dist_clear_point:
				
				for y in range(_index):
					line2d.remove_point(0)
				break
			_index += 1
	
	
func _physics_process(delta: float) -> void:
	change_state(state, delta)
	pass
	

		
func get_input(delta)->void:
	pass

func change_state(new_state, delta):
	state = new_state

	match state:
		IDLE:
			print("IDLE")
			pass
		RUN:
			print("RUN")
			face.calculate_steering(_accel)
			agent._apply_steering(_accel, delta)

			if abs(_accel.angular)>0:
				speed -= 1
				speed = clamp(speed,0,100)
			else:
				speed += 3
				speed = clamp(speed,0,150)
			pathFollow.offset += speed * delta
			velocity = position.direction_to(pathFollow.get_position()) * speed
			#	set_rotation(pathFollow.get_rotation())

			if position.distance_to(pathFollow.get_position()) > 0.1:
				velocity = move_and_slide(velocity)
			else:
				change_state(IDLE, delta)
				line2d.clear_points()
				path2d.get_curve().clear_points()

			pass
		GAIN_SPEED:
			$AnimationPlayer.play("start_speed")
			change_state(RUN, delta)
			pass
		CLEAN_UP_SPEED:
			pass
		MOORING:
			pass
		UNMOORING:
			pass
		COLLISION:
			pass
		MANEUVER:
			face.calculate_steering(_accel)
			agent._apply_steering(_accel, delta)
			pathFollow.offset += speed * delta
			
			if _accel.angular == 0:
				change_state(GAIN_SPEED, delta)
			pass


func _simplify(active_points) -> void:
	state = MANEUVER

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
	$Sprite2.visible = false
	
	
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
#	$AnimationPlayer.play('Exit')
	draw.can_move = false
	
	$Sprite2.visible = false
	

func _on_TouchScreenButton_pressed() -> void:
	TouchHelper.index += 1
	draw.index = TouchHelper.index
	_on_Plane_mouse_entered()


func _on_TouchScreenButton_released() -> void:
	TouchHelper.index -= 1
	draw.index = TouchHelper.index
	$Sprite2.visible = false
	_on_Plane_mouse_exited()
	
