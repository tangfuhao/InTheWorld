extends "res://src/character/tasks/Task.gd"
class_name Excretion
#获取目标任务
func active():
	if human:
		var target = human.target
		if target and human.is_approach(target):
			human.global_position.x = target.global_position.x
			human.global_position.y = target.global_position.y
			human.set_status_value("排泄状态",1)
			human.notify_action("排泄",true)
			print(human.player_name,"在",target.stuff_name,"排泄")
			goal_status = STATE.GOAL_COMPLETED
		else:
			print(human.player_name,"直接排泄了")
	else:
		goal_status = STATE.GOAL_FAILED
