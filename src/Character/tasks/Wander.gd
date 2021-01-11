extends "res://src/Character/tasks/Task.gd"
class_name Wander
#漫游任务

var map_position
var used_random_index_arr := []


func process(_delta: float):
	.process(_delta)
	var move_interaction = human.get_running_interaction("移动")
	if not move_interaction:
		#创建交互
		move_interaction = MoveInteractionImplement.new()
		move_interaction.human = human
		human.add_and_connect_interaction_implement(move_interaction)
		move_interaction.connect("interaction_finish",self,"_on_interaction_finish")
		var target = get_random_position()
		move_interaction.setup_target(target)


func terminate():
	.terminate()
	var move_interaction = human.get_running_interaction("移动")
	if move_interaction:
		human.break_interaction(move_interaction)


func calculate_position_by_direction(_map_position,_direction):
	if _direction == 1:
		return Vector2(map_position.x-1,map_position.y)
	elif _direction == 2:
		return Vector2(map_position.x-1,map_position.y-1)
	elif _direction == 3:
		return Vector2(map_position.x,map_position.y-1)
	elif _direction == 4:
		return Vector2(map_position.x+1,map_position.y-1)
	elif _direction == 5:
		return Vector2(map_position.x+1,map_position.y)
	elif _direction == 6:
		return Vector2(map_position.x+1,map_position.y+1)
	elif _direction == 7:
		return Vector2(map_position.x,map_position.y+1)
	elif _direction == 8:
		return Vector2(map_position.x-1,map_position.y+1)
	else:
		return map_position
#获取随机位置
func get_random_position() -> Vector2:
	var main_scence = human.get_parent().get_parent()
	var map_node = main_scence.ground
	var map_position_laste:Vector2 = map_node.world_to_map(human.get_global_position())
	if map_position != map_position_laste:
		used_random_index_arr.clear()
	map_position = map_position_laste
	
	if used_random_index_arr.size() == 8:
		return human.get_global_position()

	var random_direction = randi() % 8
	while used_random_index_arr.has(random_direction):
		random_direction = randi() % 8
	
	used_random_index_arr.push_back(random_direction)
	var random_map_position = calculate_position_by_direction(map_position,random_direction)
	return map_node.map_to_world(random_map_position)

func _on_interaction_finish(_interaction):
#	goal_status = STATE.GOAL_COMPLETED
	pass
