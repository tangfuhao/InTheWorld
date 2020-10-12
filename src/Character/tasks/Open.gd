extends "res://src/Character/tasks/NoLimitTask.gd"
class_name OpenOrUse
#打开或者使用

var player_ui
var action_time
func active():
	.active()
	
	
	action_target = get_params()
	assert(action_target and action_target is CommonStuff)
	if not action_target.can_interaction(human):
		goal_status = STATE.GOAL_FAILED
		return

	assert(action_target.get_function("可被打开","动作时间"))
	action_time = float(action_target.get_function("可被打开","动作时间"))
	
	player_ui = human.get_node("/root/Island/UI/PlayerUI")
	player_ui.show_action_bar(human,action_time)



func process(_delta: float):
	.process(_delta)
	
	action_time = action_time - _delta
	if action_time < 0:
		goal_status = STATE.GOAL_COMPLETED
	
	return goal_status
	
func terminate() ->void:
	.terminate()
	player_ui.dismiss_action_bar(human)


