#喝酒
extends "res://src/character/tasks/Task.gd"
class_name Drink

var want_to_join_group_action = null
var action_name = "喝酒"
#获取目标任务
func active()->void:
	if not human:
		goal_status = STATE.GOAL_FAILED
		pass

	var target = human.target
	if target and target is Player and target.get_current_action_name() == action_name:
		want_to_join_group_action = target.get_group_action()
		if not human.is_approach(want_to_join_group_action):
			human.movement.set_desired_position(want_to_join_group_action.task_global_position)
		else:
			want_to_join_group_action = null
			human.join_group_action(want_to_join_group_action)
			print(human.player_name,"加入喝酒")
	else:
		human.start_join_group_action(action_name)
		print(human.player_name,"开始喝酒")
	
func process(_delta: float):
	if want_to_join_group_action:
		if human.is_approach(want_to_join_group_action) and want_to_join_group_action.is_group_task_running():
			human.join_group_action(want_to_join_group_action)
			want_to_join_group_action = null
			print(human.player_name,"加入喝酒")
	return goal_status
	
func terminate() ->void:
	human.quit_group_action()
