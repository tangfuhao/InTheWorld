extends KinematicBody2D

export var player_name = "player1"
export var speed_max := 300
export var acceleration_max := 300
export var rotation_speed_max := 360
export var rotation_accel_max := 2000


#运动属性
var velocity := Vector2.ZERO
var angular_velocity := 0.0
var direction := Vector2.UP


#ai steering
onready var agent := GSAISteeringAgent.new()
onready var proxy_target := GSAIAgentLocation.new()
onready var face := GSAIFace.new(agent, proxy_target)
onready var accel := GSAITargetAcceleration.new()

#巡逻
onready var wanderController = $WanderController
onready var wanderController_Position = $WanderController/Position2D

onready var status = $Status

onready var playerName = $LabelLayout/PlayerName

func _ready() -> void:
	randomize()
	
	agent.linear_speed_max = speed_max
	agent.linear_acceleration_max = acceleration_max
	agent.angular_speed_max = deg2rad(rotation_speed_max)
	agent.angular_acceleration_max = deg2rad(rotation_accel_max)
	agent.bounding_radius = 10
	update_agent()
	update_wander()
	face.alignment_tolerance = deg2rad(5)
	face.deceleration_radius = deg2rad(45)
	
	playerName.text = player_name
	
	
func update_wander() -> void:
	wanderController.rotation_degrees = rand_range(0,360)
	proxy_target.position.x = wanderController_Position.global_position.x
	proxy_target.position.y = wanderController_Position.global_position.y
	

func _physics_process(delta: float) -> void:
	update_agent()
	update_wander()

	var movement := -1
	direction = GSAIUtils.angle_to_vector2(rotation).normalized()
	velocity = velocity.move_toward(direction * speed_max * movement,delta * acceleration_max);
	velocity = move_and_slide(velocity)
	
	

	face.calculate_steering(accel)
	if accel.angular == 0:
		angular_velocity = 0
	else:
		angular_velocity += accel.angular * delta
		angular_velocity = clamp(angular_velocity, -agent.angular_speed_max, agent.angular_speed_max)
		rotation += angular_velocity * delta
	


func update_agent() -> void:
	agent.position.x = global_position.x
	agent.position.y = global_position.y
	agent.orientation = rotation
	agent.linear_velocity.x = velocity.x
	agent.linear_velocity.y = velocity.y
	agent.angular_velocity = angular_velocity

