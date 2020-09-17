extends "res://src/character/tasks/NoLimitTask.gd"
class_name Wander
#漫游任务

func active():
	.active()

	self.action_target = human.get_target()
	if action_target and action_target.has_attribute(get_params()):
		return

	self.action_target = human.get_recent_target(get_params())
	if action_target and action_target.has_attribute(get_params()):
		return

	full_target = get_params()
	human.movement.is_on = true
	human.movement.is_wander = true
	GlobalMessageGenerator.send_player_action(human,action_name,get_params())
	human.visionSensor.connect("vision_find_player",self,"_on_charactar_find_something")
	human.visionSensor.connect("vision_find_stuff",self,"_on_charactar_find_something")

func process(_delta: float):
	.process(_delta)
	if action_target:
		goal_status =  STATE.GOAL_COMPLETED

	return goal_status

func terminate():
	.terminate()
	human.movement.is_wander = false
	human.movement.is_on = false
	human.movement.direction = Vector2.ZERO
	human.disconnect("vision_find_player",self,"_on_charactar_find_something")
	human.disconnect("vision_find_stuff",self,"_on_charactar_find_something")
		

func _on_charactar_find_something(body):
	if body.has_attribute(get_params()):
		self.action_target = body
