extends "res://src/character/tasks/Task.gd"
class_name PickUp

func process(_delta: float):
	if human:
		var target = human.get_target()
		if target:
			if target is Stuff:
				if human.is_approach(target):
					human.pick_up(target)
					return STATE.GOAL_COMPLETED
			else:
				print("拾取物品 类型错误")
	return STATE.GOAL_FAILED

