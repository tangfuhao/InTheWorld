extends "res://src/Character/tasks/NoLimitTask.gd"
class_name MoveTo
#接近目标的任务

var target
var interaction_distance
var path_finding



func active():
	.active()
	
	#目标位置 
	target = get_index_params(0)
	#交互距离
	interaction_distance = get_index_params(1)
	
	path_finding = human.get_tree("/Pathfinding")

	if human.is_approach(target,interaction_distance):
		goal_status = STATE.GOAL_COMPLETED
	else:
		path_finding()
		
		human.movement.set_desired_position(target)
		human.movement.is_on = true

func path_finding():
	var path_world = path_finding.get_new_path(human.global_postion,target)
	if path_world.size() > 1:
		actor_velocity = actor.velocity_toward(path_world[1])
		actor.rotate_toward(path[1])
		actor.move_and_slide(actor_velocity)
		set_path_line(path_world)
	else:
		path_line.clear_points()

func process(_delta: float):
	.process(_delta)
	
	


#	if not action_target:
#		goal_status = STATE.GOAL_FAILED
#
#	if goal_status != STATE.GOAL_ACTIVE:
#		return goal_status

	
	if human.is_approach(target,interaction_distance):
		goal_status = STATE.GOAL_COMPLETED

	return goal_status

func terminate():
	.terminate()
	
	human.set_status_value("体力状态",0.5)
	human.movement.is_on = false
	human.movement.direction = Vector2.ZERO
		
		
