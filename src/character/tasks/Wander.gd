extends "res://src/character/tasks/NoLimitTask.gd"
class_name Wander
#漫游任务

var find_stuff

func active():
	.active()
	# print("周围移动寻找激活")
	if human:
		var target = human.get_target()
		if not target or not target.has_attribute(get_params()):
			target = human.get_recent_target(get_params())
			
		if target:
			find_stuff = target
		else:
			human.movement.is_on = true
			human.movement.is_wander = true
			GlobalMessageGenerator.send_player_action(human,action_name,get_params())
			human.visionSensor.connect("vision_find_player",self,"_on_charactar_find_something")
			human.visionSensor.connect("vision_find_stuff",self,"_on_charactar_find_something")


func process(_delta: float):
	if find_stuff:
		# print(human.player_name,"周围移动寻找完成")
		return STATE.GOAL_COMPLETED
	else:
		return STATE.GOAL_ACTIVE

func terminate():
	if human:
		# print(human.player_name,"周围移动寻找结束")
		human.movement.direction = Vector2.ZERO
		human.movement.is_wander = false
		human.movement.is_on = false
		human.disconnect("vision_find_player",self,"_on_charactar_find_something")
		human.disconnect("vision_find_stuff",self,"_on_charactar_find_something")
		
func _on_charactar_find_something(body):
	if body.has_attribute(get_params()):
		find_stuff = body
