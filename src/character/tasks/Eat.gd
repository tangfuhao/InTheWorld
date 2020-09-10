extends "res://src/character/tasks/Task.gd"
class_name Eat
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		var edible_name = get_params()
		if edible_name:
			var item = human.inventory_system.pop_item_by_name_in_package(edible_name)
			if not item:
				item = human.inventory_system.pop_item_by_function_name_in_package(edible_name)

			if item:
				# print(human.player_name,"吃",item.item_name)
				GlobalMessageGenerator.send_player_action(human,action_name,item)
				human.set_status_value("饥饿状态",1)
				goal_status = STATE.GOAL_COMPLETED
				return
		elif target:
			if human.is_approach(target):
				GlobalMessageGenerator.send_player_action(human,action_name,target)
				# print(human.player_name,"吃",target.stuff_name)
				human.set_status_value("饥饿状态",1)
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED
