extends "res://src/character/tasks/NoLimitTask.gd"
class_name TakeABath

var action_timer:Timer = null
var finish_take_a_bath = false

#获取目标任务
func active():
	.active()
	create_action_timer()
	
	if human:
		var target = human.get_target()
		if target:
			if human.is_approach(target) and target.can_interaction(human):
				human.global_position.x = target.global_position.x
				human.global_position.y = target.global_position.y
				human.take_off_clothes()
				print(human.player_name,"在",target.stuff_name,"洗澡")
				action_timer.start(5)
				return
				
	goal_status = STATE.GOAL_FAILED

func create_action_timer():
	if action_timer == null:
		action_timer = Timer.new()
		human.add_child(action_timer)
		action_timer.connect("timeout",self,"_on_action_timer_time_out")
		
func process(_delta: float):
	if finish_take_a_bath:
		human.set_status_value("清洁状态",1)
		human.to_wear_clothes()
		goal_status = STATE.GOAL_COMPLETED
	return goal_status
		
		
func _on_action_timer_time_out():
	finish_take_a_bath = true

func terminate() ->void:
	if action_timer:
		human.remove_child(action_timer)
		action_timer = null
