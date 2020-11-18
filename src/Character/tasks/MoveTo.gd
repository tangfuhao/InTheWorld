extends "res://src/Character/tasks/NoLimitTask.gd"
class_name MoveTo
#接近目标的任务

var target_pos

var path_world:Array
var next_destination = null



var exercise_transform = 0
func active():
	.active()
	
	
	#目标位置 
	setup_target()
	if is_reach_target():
		goal_status = STATE.GOAL_COMPLETED
		return


	path_world = path_finding()
	if path_world.size() > 0:
		human.movement.is_on = true
		path_world.pop_front()
		plan_next_destination()
		update_movement()

	else:
		goal_status = STATE.GOAL_FAILED
	
func update_movement():
	var exercise_transform_temp = get_player_exercise_transform(human)
	if exercise_transform != exercise_transform_temp:
		var exercise =  human.get_param_value("当前运动量")
		exercise = exercise - exercise_transform + exercise_transform_temp
		exercise_transform = exercise_transform_temp
		human.set_param_value("当前运动量",exercise)




func process(_delta: float):
	.process(_delta)
	
	if goal_status != STATE.GOAL_ACTIVE:
		return goal_status
		
	if is_reach_target():
		goal_status = STATE.GOAL_COMPLETED
		return goal_status
		
	update_movement()
	
	if next_destination and human.is_approach(next_destination,10):
		next_destination = null
		plan_next_destination()


	return goal_status
	

func terminate():
	.terminate()
	human.movement.is_on = false
	human.movement.direction = Vector2.ZERO
	if exercise_transform:
		var exercise =  human.get_param_value("当前运动量")
		exercise = exercise - exercise_transform
		human.set_param_value("当前运动量",exercise)

func setup_target():
	action_target = get_index_params(0)
	if action_target is CommonStuff:
		target_pos = action_target.get_global_position()
	else:
		target_pos = action_target
	
func is_reach_target():
	if action_target is CommonStuff:
		return action_target.can_interaction(human)
	else:
		return human.is_approach(target_pos,10)

func plan_next_destination():
	next_destination = path_world.pop_front()
	if next_destination:
		if path_world.empty() and human.get_global_position().distance_to(target_pos) <= human.get_global_position().distance_to(next_destination):
			human.movement.set_desired_position(target_pos)
		else:
			human.movement.set_desired_position(next_destination)
	else:
		human.movement.set_desired_position(target_pos)
	
	
func path_finding():
	var path_finding = human.get_node("/root/Island/Pathfinding")
	if action_target is CommonStuff and not action_target.is_location:
		var stuff_interaction_coord_arr = path_finding.get_stuff_interaction_coords(action_target)
		var min_distance = 5000000000
		var min_coord
		for coord in stuff_interaction_coord_arr:
			var distance = human.get_global_position().distance_to(coord)
			if distance < min_distance:
				min_coord = coord
				min_distance = distance
		if min_coord:
			var path_world = path_finding.get_new_path(human.get_global_position(),min_coord)
			return path_world
		else:
			return []
	else:
		var path_world = path_finding.get_new_path(human.get_global_position(),target_pos)
		return path_world


func get_player_exercise_transform(_human):
	if _human.movement.move_state == "move":
		return 0.0005
	elif _human.movement.move_state == "run":
		return 0.002
	elif _human.movement.move_state == "walk":
		return 0.0003
	return 0
