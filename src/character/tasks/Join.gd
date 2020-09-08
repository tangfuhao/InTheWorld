extends "res://src/character/tasks/Task.gd"
class_name Join

var want_to_join_group_action = null
var join_action_name
var is_quit_task
#获取目标任务
func active()->void:
	if not human:
		goal_status = STATE.GOAL_FAILED
		return

	var target = human.get_target()
	if target and target is Player and target.get_current_action_name() == get_params():
		want_to_join_group_action = target.get_group_action()
		join_action_name = want_to_join_group_action.action_name
		if not human.is_interaction_distance(want_to_join_group_action):
			human.movement.is_on = true
			human.movement.set_desired_position(want_to_join_group_action.global_position)
		else:
			print(human.player_name,"加入",join_action_name)
			want_to_join_group_action.connect("task_quit",self,"_on_group_task_quit")
			human.join_group_action(want_to_join_group_action)
			human.notify_action(join_action_name,true)
			want_to_join_group_action = null
	else:
		goal_status = STATE.GOAL_FAILED
		
func _on_group_task_quit():
	is_quit_task = true

func process(_delta: float):
	if is_quit_task:
		goal_status = STATE.GOAL_COMPLETED
		return goal_status

	if want_to_join_group_action and human.is_interaction_distance(want_to_join_group_action) and want_to_join_group_action.is_group_task_running():
		human.movement.is_on = false
		print(human.player_name,"加入",join_action_name)
		want_to_join_group_action.connect("task_quit",self,"_on_group_task_quit")
		human.join_group_action(want_to_join_group_action)
		want_to_join_group_action.connect("")
		human.notify_action(join_action_name,true)
		want_to_join_group_action = null

	return goal_status
	
#func terminate() ->void:
#	human.movement.is_on = false
#	human.quit_group_action()
#	human.notify_action(join_action_name,false)
