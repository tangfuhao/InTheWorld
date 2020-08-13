extends "res://src/character/tasks/Task.gd"
class_name Wander
#漫游任务

var player_detection_zone:VisionSensor
var find_stuff

func active():
#	print("周围移动寻找激活")
	if human:
#		print(human.player_name,"周围移动寻找激活")
		human.movement.is_on = true
		human.movement.is_wander = true
		
		player_detection_zone = human.cpu.player_detection_zone
		#TODO 是否该如此指定target
		var target = player_detection_zone.get_recent_target("其他人")
		if target :
			find_stuff = target
		else:
			player_detection_zone.connect("find_new_something",self,"find_new_something")

func process(_delta: float):
	if human:
		if find_stuff:
#			print(human.player_name,"周围移动寻找完成")
			return STATE.GOAL_COMPLETED
		else:
			return STATE.GOAL_ACTIVE
#	print(human.player_name,"周围移动寻找失败")
	return STATE.GOAL_FAILED

func terminate():
	if human:
#		print(human.player_name,"周围移动寻找结束")
		human.movement.direction = Vector2.ZERO
		human.movement.is_wander = false
		
func find_new_something(body):
	if body.has_attribute(params):
		find_stuff = body