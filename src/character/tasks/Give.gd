#赠送
extends "res://src/character/tasks/Task.gd"
class_name Give
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			var item = human.inventory_system.pop_item_by_function_name_in_package(get_params())
			if item:
				GlobalMessageGenerator.send_player_action(human,action_name,target)
				target.inventory_system.add_item_to_package(item)
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED
