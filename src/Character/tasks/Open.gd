extends "res://src/Character/tasks/NoLimitTask.gd"
class_name OpenOrUse
#打开或者使用

var action_time
func active():
	.active()
	
	action_target = get_params()

	if not human.is_approach(action_target.get_global_position(),10):
		goal_status = STATE.GOAL_FAILED
	else:
		var function_attribute = action_target.get_function("可被打开")
		if function_attribute:
			action_time = float(function_attribute["动作时间"])
			var player_ui = human.get_node("/root/Island/UI/PlayerUI")
			player_ui.show_action_bar(human,action_time)
		else:
			goal_status = STATE.GOAL_FAILED


func process(_delta: float):
	.process(_delta)
	
	action_time = action_time - _delta
	if action_time < 0:
		goal_status = STATE.GOAL_COMPLETED
	
	return goal_status
	
func terminate() ->void:
	.terminate()
	print("open terminate")
	pass

