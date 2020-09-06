#赠送
extends "res://src/character/tasks/Task.gd"
class_name Give
#获取目标任务
func active():
	.active()
	if human:
		var target = human.target
		if target and target is Player:
			print(human.player_name,"赠送",target.player_name)
			var item = human.pop_item_by_function_name_in_package(get_params())
			if item:
				target.package.push_back(item)
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED
