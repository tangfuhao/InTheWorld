extends "res://src/character/tasks/Task.gd"
class_name Wander
#漫游任务

var player_detection_zone:VisionSensor
var find_stuff

func active():
	if human:
		human.movement.is_wander = true
		player_detection_zone = human.cpu.player_detection_zone
		player_detection_zone.connect("find_new_something",self,"find_new_something")

func process(_delta: float):
	if human:
		if find_stuff:
			return STATE.GOAL_COMPLETED
		else:
			return STATE.GOAL_ACTIVE
	return STATE.GOAL_FAILED

func terminate():
	if human:
		human.movement.is_wander = false
		
func find_new_something(body:Stuff):
	if body.has_attribute(params):
		find_stuff = body
