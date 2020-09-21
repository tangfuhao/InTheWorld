extends "res://src/Character/tasks/NoLimitTask.gd"
class_name TakeABath
#获取目标任务

var action_timer:Timer = null
var finish_take_a_bath = false


func create_action_timer():
	if action_timer == null:
		action_timer = Timer.new()
		human.add_child(action_timer)
		action_timer.connect("timeout",self,"_on_action_timer_time_out")

func _on_action_timer_time_out():
	finish_take_a_bath = true

func active():
	.active()
	create_action_timer()

	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return 

	if not human.is_interaction_distance(action_target):
		goal_status = STATE.GOAL_FAILED
		return 

	#TODO 通用的被占用
	# if action_target.is_be_occupied(action_target):
	# 	pass 

#	if not action_target.can_interaction(human):
#		goal_status = STATE.GOAL_FAILED
#		return 
	
	status_recover = true
	human.global_position.x = action_target.global_position.x
	human.global_position.y = action_target.global_position.y
	human.take_off_clothes()
	action_timer.start(10)


		
func process(_delta: float):
	.process(_delta)
	if finish_take_a_bath:
		human.to_wear_clothes()
		goal_status = STATE.GOAL_COMPLETED
	return goal_status



func terminate() ->void:
	.terminate()

	if status_recover:
		human.set_status_value("清洁状态",1)

	if action_timer:
		action_timer.stop()
		human.remove_child(action_timer)
		action_timer = null


