extends Node2D

export(NodePath) var control_obj
onready var control_node:Player = get_node(control_obj)

#ai steering
onready var agent := GSAISteeringAgent.new()
onready var proxy_target := GSAIAgentLocation.new()
onready var face := GSAIFace.new(agent, proxy_target)
onready var accel := GSAITargetAcceleration.new()

var is_wander = false
var is_on = false
#巡逻
onready var wanderController = $WanderController
onready var wanderController_Position = $WanderController/Position2D
onready var wall_avoid_ray = $WallAvoidRay

export var speed_max := 100
export var acceleration_max := 500
export var rotation_speed_max := 360
export var rotation_accel_max := 2000

#运动属性
var velocity := Vector2.ZERO
var angular_velocity := 0.0
var direction := Vector2.ZERO

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

	face.alignment_tolerance = deg2rad(5)
	face.deceleration_radius = deg2rad(45)

func _physics_process(_delta: float) -> void:
	update_agent()
	var movement := -1
	
	if is_on:
		if is_wander:
			#随机rotation
			update_wander()
		#计算位移
		direction = GSAIUtils.angle_to_vector2(control_node.rotation).normalized()
		if is_wander && wall_avoid_ray.is_colliding():
			var closest_point_distance = wall_avoid_ray.get_collision_point().distance_to(global_position)
			var avoid_force_scale = (50 - closest_point_distance) / 20
#
			var wall_avoid_force = wall_avoid_ray.get_collision_normal() * avoid_force_scale * movement
			direction = direction + wall_avoid_force
			direction = direction.normalized()
		else:
			#计算朝向
			face.calculate_steering(accel)
			if accel.angular == 0:
				angular_velocity = 0
			else:
				angular_velocity += accel.angular * _delta
				angular_velocity = clamp(angular_velocity, -agent.angular_speed_max, agent.angular_speed_max)
				control_node.rotation += angular_velocity * _delta
			
			

			
			
			

	else:
		direction = Vector2.ZERO

	velocity = velocity.move_toward(direction * speed_max * movement, _delta * acceleration_max);
	velocity = control_node.move_and_slide(velocity)
	
	if is_wander && wall_avoid_ray.is_colliding():
		control_node.rotation = velocity.angle()



	
	
func update_wander() -> void:
	wanderController.rotation_degrees = rand_range(0,360)
	proxy_target.position.x = wanderController_Position.global_position.x
	proxy_target.position.y = wanderController_Position.global_position.y

func update_agent() -> void:
	agent.position.x = global_position.x
	agent.position.y = global_position.y
	agent.orientation = control_node.rotation
	agent.linear_velocity.x = velocity.x
	agent.linear_velocity.y = velocity.y
	agent.angular_velocity = angular_velocity
	
func set_desired_position(_desired_position:Vector2):
	proxy_target.position.x = _desired_position.x
	proxy_target.position.y = _desired_position.y
