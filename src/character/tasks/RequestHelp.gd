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
				# print(human.player_name,"向",item.player_name,"发布求助:",get_params())
	
	if request_succus:
		excute_action = true
		GlobalMessageGenerator.send_player_action(human,action_name,null)
		var encode_task_name = "%s-%s" % [human.player_name, get_params()]
		human.wait_for_help_flag = encode_task_name
		#TODO 记录发布
	else:
		goal_status = STATE.GOAL_FAILED

#等待求组完成
func process(_delta: float):
	if human.wait_for_help():
		goal_status = STATE.GOAL_COMPLETED
	
	return goal_status

	
func terminate() ->void:
	human.wait_for_help_flag = null

	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,null)
