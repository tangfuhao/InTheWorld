extends "res://src/character/tasks/Task.gd"
class_name PickUp

var is_picked = false
func active() ->void:
	if human:
		var target = human.get_target()
		if target:
			if target is CommonStuff:
				if human.is_approach(target):
					human.pick_up(target)
					is_picked = true

func process(_delta: float):
	if is_picked:
		return STATE.GOAL_COMPLETED
	else:
		print("拾取物品 类型错误")
		return STATE.GOAL_FAILED


