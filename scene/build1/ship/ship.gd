extends KinematicBody2D

signal path_established(path,line,draw)
signal path_delete(path,line)

enum {IDLE, RUN, GAIN_SPEED, CLEAN_UP_SPEED, MOORING, UNMOORING, COLLISION, MANEUVER, LAODING}

export (int, 0, 1080, 2) var angular_speed_max := 1000
export (int, 0, 2048, 2) var angular_accel_max := 1500
export (int, 0, 180, 2) var align_tolerance := 10
export (int, 0, 359, 2) var deceleration_radius := 10
export (float, 0, 1000, 40) var player_speed := 900.0

export (PackedScene) var draw
export (int, 0, 1080, 2) var top_speed = 100


export(String, FILE) var repair
export(String, FILE) var fuel
export(String, FILE) var cargo
export(String, FILE) var exit

onready var status:Dictionary = {"FUEL":fuel,"CARGO":cargo,"REPAIR":repair,"EXIT":exit}


var speed = 100
var state
var velocity := Vector2()
var if_add_child := true
var distance_threshold := 20.0
var dist_clear_point := 20.0
var face : GSAIFace
var agent := GSAIKinematicBody2DAgent.new(self)
var _accel := GSAITargetAcceleration.new()
var _angular_drag := 0.1

var berth

var sequtense:Array
var my_status:Array



onready var follow_scripts = preload('res://scene/protatape/StearingAiVersion/Follow_target.gd')
onready var path2d:Path2D = Path2D.new()
onready var pathFollow:PathFollow2D = PathFollow2D.new()
onready var line2d:Line2D = Line2D.new()
onready var curve:Curve2D = Curve2D.new()

onready var timer : = $Timer
var is_timer = false



func _ready() -> void:
	yield(get_parent(),"ok")
	print(status)
	randomize()
	sequtense = status.keys().duplicate()
	get_status_sequtense()
	print(my_status)


	state = IDLE

	draw = draw.instance()
	draw.connect("simlify",self,"_simplify")
	# Crutch for multitouch
	draw.index = 100
	draw.ship = self
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



	$"Node2D/status".texture = load(status[my_status[0]])

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
	$Node2D.global_rotation_degrees = 0
	$Node2D.global_position = global_position + Vector2(50,-50)

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

func get_status_sequtense()->void:
	print(len(sequtense))
	for x in range(rand_range(1,len(sequtense))):
		my_status.append(sequtense[x])

	my_status.shuffle()
	my_status.append(sequtense[len(sequtense)-1])


func change_status()->void:
	$"Node2D/status".texture = load(status[my_status[0]])


func get_input(delta)->void:
	pass

func change_state(new_state, delta):
	state = new_state

	match state:
		IDLE:
			$Node2D/Label.set_text("IDLE")
			line2d.clear_points()

		RUN:
			$Node2D/Label.set_text("RUN")
			face.calculate_steering(_accel)
			agent._apply_steering(_accel, delta)

			if abs(_accel.angular)>0:
				speed -= 2
				speed = clamp(speed,0, top_speed)
			else:
				speed += 3
				speed = clamp(speed,0, top_speed)
			pathFollow.offset += (speed + 3) * delta
			velocity = position.direction_to(pathFollow.get_position()) * speed
			#	set_rotation(pathFollow.get_rotation())

			if position.distance_to(pathFollow.get_position()) > 5:
				velocity = move_and_slide(velocity)
			else:
				change_state(IDLE, delta)
				line2d.clear_points()
				path2d.get_curve().clear_points()


		GAIN_SPEED:
			$Node2D/Label.set_text("GAIN_SPEED")
			change_state(RUN, delta)

		CLEAN_UP_SPEED:
			pass
		MOORING:
			$Node2D/Label.set_text("MOORING")
			$TouchScreenButton.visible = false
			if not $Tween.is_active():
				mooring(berth.get_node("Area2D").global_position, berth.global_rotation_degrees,2.0)
			yield($Tween,'tween_completed')
			is_timer = true

			change_state(LAODING,delta)

		UNMOORING:
			$Node2D/Label.set_text("UNMOORING")
			$TouchScreenButton.visible = false
			if not $Tween.is_active():

				mooring(berth.get_node("Position2D").global_position,berth.global_rotation_degrees,1.0)

			yield($Tween,'tween_all_completed')

			$TouchScreenButton.visible = true
			change_state(IDLE,delta)


		COLLISION:
			pass
		MANEUVER:
			$Node2D/Label.set_text("MANEUVER")
			speed = 90
			face.calculate_steering(_accel)
			agent._apply_steering(_accel, delta)
			pathFollow.offset += speed * delta

			yield(get_tree().create_timer(0.2),'timeout')
			if _accel.angular == 0:
				change_state(GAIN_SPEED, delta)

		LAODING:
			$Node2D/Label.set_text("LAODING")
			$TouchScreenButton.visible = false
			if is_timer:
				timer.start()
				line2d.clear_points()
				is_timer = false


func mooring(berth_pos , berth_angle , dutarion:float)->void:
	if berth.global_rotation_degrees - rotation_degrees > 90:
		$Tween.interpolate_property(self,"rotation_degrees",rotation_degrees,-berth_angle,dutarion,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
	else:
		$Tween.interpolate_property(self,"rotation_degrees",rotation_degrees,berth_angle,dutarion,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)

	$Tween.interpolate_property(self,"position",position,berth_pos,dutarion,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
	$Tween.start()

func _simplify(active_points:Array) -> void:
	active_points.push_front(global_position)
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
#	TODO make optimazation
	curve.set_bake_interval(5)

	line2d.set_points(curve.get_baked_points())
	$choiceSprite.visible = false

	if if_add_child:
		emit_signal("path_established", path2d, line2d, draw)
		if_add_child = false

	change_state(MANEUVER,0.01)

func _on_TouchScreenButton_pressed() -> void:
	TouchHelper.index += 1
	draw.index = TouchHelper.index
	line2d.clear_points()
	path2d.get_curve().clear_points()
	change_state(IDLE,0.01)
	speed = 0
	draw.can_move = true

	if if_add_child:
		emit_signal("path_established", path2d, line2d, draw)
		if_add_child = false

func _on_TouchScreenButton_released() -> void:
	TouchHelper.index -= 1
	draw.index = TouchHelper.index
	$choiceSprite.visible = false
	draw.can_move = false
	$choiceSprite.visible = false


func _on_Timer_timeout_unmooring() -> void:
	my_status.remove(0)
	change_status()
	change_state(UNMOORING,0.01)
