#赠送
extends "res://src/character/tasks/Task.gd"
class_name Give
#获取目标任务


var action_target

func active():
	.active()
	if human:
		action_target = human.get_target()
		if action_target:
			var item = human.inventory_system.pop_item_by_function_name_in_package(get_params())
			if item:
				excute_action = true
				GlobalMessageGenerator.send_player_action(human,action_name,action_target)
				action_target.inventory_system.add_item_to_package(item)
				
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED


func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,action_target)