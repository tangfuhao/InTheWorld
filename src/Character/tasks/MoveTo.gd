extends "res://src/Character/tasks/NoLimitTask.gd"
class_name MoveTo
#接近目标的任务

var target_pos
var interaction_distance
var path_world:Array
var next_destination = null


func active():
	.active()
	
	#目标位置 
	target_pos = get_index_params(0)
	#交互距离x
	interaction_distance = 45.3
#	interaction_distance = get_index_params(1)
	
	

	if human.is_approach(target_pos,10):
		goal_status = STATE.GOAL_COMPLETED
	else:
		path_world = path_finding()
		if path_world.size() > 0:
			path_world.pop_front()
			next_destination = path_world.pop_front()
			
			if next_destination:
				if path_world.empty() and human.get_global_position().distance_to(target_pos) <= human.get_global_position().distance_to(next_destination):
					human.movement.set_desired_position(target_pos)
				else:
					human.movement.set_desired_position(next_destination)
			else:
				human.movement.set_desired_position(target_pos)
				
			human.movement.is_on = true
		else:
			goal_status = STATE.GOAL_FAILED
		

func path_finding():
	var path_finding = human.get_node("/root/Island/Pathfinding")
	var path_world = path_finding.get_new_path(human.get_global_position(),target_pos)
	return path_world
	

func process(_delta: float):
	.process(_delta)
	
	if goal_status != STATE.GOAL_ACTIVE:
		return goal_status
	
	if next_destination and human.is_approach(next_destination,10):
		next_destination = null
		next_destination = path_world.pop_front()

		if next_destination:
			if path_world.empty() and human.get_global_position().distance_to(target_pos) <= human.get_global_position().distance_to(next_destination):
				human.movement.set_desired_position(target_pos)
			else:
				human.movement.set_desired_position(next_destination)
		else:
			human.movement.set_desired_position(target_pos)

	
	if human.is_approach(target_pos,10):
		goal_status = STATE.GOAL_COMPLETED


	return goal_status

func terminate():
	.terminate()
	human.movement.is_on = false
	human.movement.direction = Vector2.ZERO
		
		
