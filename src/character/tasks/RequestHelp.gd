#发布求组
extends "res://src/character/tasks/Task.gd"
class_name RequestHelp
func active() ->void:
	.active()
	var request_succus = false
	if human:
		var world = human.owner
		var all_player_arr = world.all_player_arr
		for item in all_player_arr:
			if item != human:
				request_succus = true
				item.help_for_request(human,get_params())
				print(human.player_name,"向",item.player_name,"发布求助:",get_params())
	
	if request_succus:
		human.cpu.strategy.ignore_status_change_re_plan = true
		#TODO 记录发布
	else:
		goal_status = STATE.GOAL_FAILED
		
	
func terminate() ->void:
	human.cpu.strategy.ignore_status_change_re_plan = false
