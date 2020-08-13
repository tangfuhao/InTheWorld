extends "res://src/character/tasks/Task.gd"
class_name ApproachToTarget
#接近目标的任务

func active():
#	print("移动到目标激活")
	if human:
#		print(human.player_name,"移动到目标激活")
		human.movement.is_on = true

func process(_delta: float):
	if human:
		var target = human.get_target()
		if target:
			if human.is_approach(target):
#				print(human.player_name,"移动到目标成功")
				return STATE.GOAL_COMPLETED
			else:
#				var direction:Vector2 = human.global_position - target.global_position
#				direction = direction.normalized()
				human.movement.set_desired_position(target.global_position)
				return STATE.GOAL_ACTIVE
#	print(human.player_name,"移动到目标失败")
	return STATE.GOAL_FAILED

func terminate():
	if human:
#		print(human.player_name,"移动到目标结束")
		human.movement.is_on = false
		human.movement.direction = Vector2.ZERO
		
