extends KinematicBody2D
class_name Player



export var player_name = "player1"
export var speed_max := 300
export var acceleration_max := 300
export var rotation_speed_max := 360
export var rotation_accel_max := 2000


#运动属性
var velocity := Vector2.ZERO
var angular_velocity := 0.0
var direction := Vector2.ZERO


#ai steering
onready var agent := GSAISteeringAgent.new()
onready var proxy_target := GSAIAgentLocation.new()
onready var face := GSAIFace.new(agent, proxy_target)
onready var accel := GSAITargetAcceleration.new()

#巡逻
onready var wanderController = $WanderController
onready var wanderController_Position = $WanderController/Position2D

onready var status = $Status
onready var motivation = $Motivation
onready var strategy = $Strategy
onready var world_status = $WorldStatus
onready var player_detection_zone = $PlayerDetectionZone
onready var playerName = $LabelLayout/PlayerName

#目标
var target = null setget set_target,get_target
var is_wander = false

func _ready() -> void:
	
	randomize()
	
	agent.linear_speed_max = speed_max
	agent.linear_acceleration_max = acceleration_max
	agent.angular_speed_max = deg2rad(rotation_speed_max)
	agent.angular_acceleration_max = deg2rad(rotation_accel_max)
	agent.bounding_radius = 10
	update_agent()
	proxy_target.position.x = global_position.x
	proxy_target.position.y = global_position.y
#	update_wander()
	face.alignment_tolerance = deg2rad(5)
	face.deceleration_radius = deg2rad(45)
	playerName.text = player_name
	
	status.setup()
	motivation.setup()
	strategy.setup()
	world_status.setup()
	

func _process(_delta: float):
	strategy.process_task(_delta)

func _physics_process(_delta: float) -> void:
	update_agent()
	var movement := -1
	
	if is_wander:
		update_wander()
		#计算位移
		direction = GSAIUtils.angle_to_vector2(rotation).normalized()
	velocity = velocity.move_toward(direction * speed_max * movement, _delta * acceleration_max);
	velocity = move_and_slide(velocity)


	#计算朝向
	face.calculate_steering(accel)
	if accel.angular == 0:
		angular_velocity = 0
	else:
		angular_velocity += accel.angular * _delta
		angular_velocity = clamp(angular_velocity, -agent.angular_speed_max, agent.angular_speed_max)
		rotation += angular_velocity * _delta
	
	
func update_wander() -> void:
	wanderController.rotation_degrees = rand_range(0,360)
	proxy_target.position.x = wanderController_Position.global_position.x
	proxy_target.position.y = wanderController_Position.global_position.y

func update_agent() -> void:
	agent.position.x = global_position.x
	agent.position.y = global_position.y
	agent.orientation = rotation
	agent.linear_velocity.x = velocity.x
	agent.linear_velocity.y = velocity.y
	agent.angular_velocity = angular_velocity
	
	
func set_target(_target):
	target = _target
func get_target():
	return target

