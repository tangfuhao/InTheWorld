extends "res://src/character/tasks/Task.gd"
class_name Join

var want_to_join_group_action = null
var join_action_name
var is_quit_task


#获取目标任务
func active()->void:
	.active()


	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return

	if action_target.get_current_action_name() != get_params():
		goal_status = STATE.GOAL_FAILED
		return


	want_to_join_group_action = action_target.get_group_action()

	if not want_to_join_group_action:
		goal_status = STATE.GOAL_FAILED
		return

	if not human.is_interaction_distance(want_to_join_group_action):
		goal_status = STATE.GOAL_FAILED
		return


	join_action_name = want_to_join_group_action.action_name
	full_action = join_action_name

	want_to_join_group_action.connect("task_quit",self,"_on_group_task_quit")
	human.join_group_action(want_to_join_group_action)
	#TODO 这里怎么处理
	# human.notify_action(join_action_name,true)

		
func _on_group_task_quit():
	is_quit_task = true

func process(_delta: float):
	.process(_delta)
	if is_quit_task:
		human.movement.is_on = false
		goal_status = STATE.GOAL_COMPLETED
		return goal_status

	if not want_to_join_group_action:
		human.movement.is_on = false
		goal_status = STATE.GOAL_COMPLETED		
		return goal_status

	if not want_to_join_group_action.is_group_task_running():
		human.movement.is_on = false
		goal_status = STATE.GOAL_COMPLETED
		return goal_status

	if goal_status == STATE.GOAL_ACTIVE:
		human.movement.set_desired_position(want_to_join_group_action.global_position)
		if not human.is_interaction_distance(want_to_join_group_action):
			human.movement.is_on = true	
		else:
			human.movement.is_on = false

	return goal_status
