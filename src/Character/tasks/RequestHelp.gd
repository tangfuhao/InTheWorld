extends "res://src/character/tasks/Task.gd"
class_name RequestHelp
#发布求组

func active() ->void:
	.active()
	var request_succus = false

	var world = human.owner
	var all_player_arr = world.all_player_arr
	for item in all_player_arr:
		if item != human:
			request_succus = true
			item.help_for_request(human,get_params())
				# print(human.player_name,"向",item.player_name,"发布求助:",get_params())
	
	if request_succus:
		var encode_task_name = "%s-%s" % [human.player_name, get_params()]
		human.wait_for_help_flag = encode_task_name
		#TODO 记录发布
	else:
		goal_status = STATE.GOAL_FAILED

#等待求组完成
func process(_delta: float):
	.process(_delta)

	if human.wait_for_help():
		goal_status = STATE.GOAL_COMPLETED
	
	return goal_status

	
func terminate() ->void:
	.terminate()
	human.wait_for_help_flag = null
