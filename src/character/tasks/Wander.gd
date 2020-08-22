extends "res://src/character/tasks/Task.gd"
class_name Wander
#漫游任务

var player_detection_zone:VisionSensor
var find_stuff

func active():
	print("周围移动寻找激活")
	if human:
		print(human.player_name,"周围移动寻找激活")
		human.movement.is_on = true
		human.movement.is_wander = true
		init_search()

func init_search():
	var player_detection_zone = human.cpu.player_detection_zone
	var target = player_detection_zone.get_recent_target(params)
	if target:
		find_stuff = target
	else:
		player_detection_zone.connect("find_something",self,"find_something")


func process(_delta: float):
	if find_stuff:
		print(human.player_name,"周围移动寻找完成")
		return STATE.GOAL_COMPLETED
	else:
		return STATE.GOAL_ACTIVE

func terminate():
	if human:
		print(human.player_name,"周围移动寻找结束")
		human.movement.direction = Vector2.ZERO
		human.movement.is_wander = false
		human.movement.is_on = false
		
func find_something(body):
	if body.has_attribute(params):
		find_stuff = body
