extends "res://src/character/tasks/Task.gd"
class_name TakeABath
#获取目标任务
func active():
	if human:
		var target = human.target
		if target:
			if human.is_approach(target):
				human.global_position.x = target.global_position.x
				human.global_position.y = target.global_position.y
				print(human.player_name,"在",target.stuff_name,"洗澡")
				return
				
	goal_status = STATE.GOAL_FAILED