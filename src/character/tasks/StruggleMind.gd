extends "res://src/character/tasks/NoLimitTask.gd"
class_name StruggleMind
func active() ->void:
	.active()
	if human:
		# print(human.player_name,"纠结")
		excute_action = true
		GlobalMessageGenerator.send_player_action(human,action_name,null)
		human.set_status_value("爱情动机",0.9)


func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,null)