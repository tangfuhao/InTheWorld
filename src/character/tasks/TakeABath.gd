extends "res://src/character/tasks/NoLimitTask.gd"
class_name TakeABath
#获取目标任务

var action_timer:Timer = null
var finish_take_a_bath = false

var action_target




func active():
	.active()
	create_action_timer()
	
	if human:
		action_target = human.get_target()
		if action_target:
			if human.is_approach(action_target) and action_target.can_interaction(human):
				human.global_position.x = action_target.global_position.x
				human.global_position.y = action_target.global_position.y
				human.take_off_clothes()
				excute_action = true
				GlobalMessageGenerator.send_player_action(human,action_name,action_target)
				# print(human.player_name,"在",target.stuff_name,"洗澡")
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

	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,action_target)
