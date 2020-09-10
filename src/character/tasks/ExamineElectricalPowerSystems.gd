extends "res://src/character/tasks/Task.gd"
class_name ExamineElectricalPowerSystems
func active() ->void:
	if human:
		# print(human.player_name,"检查电力系统")
		# human.notify_action("检查电力系统",true)
		human.notify_action(action_name,true)
		GlobalMessageGenerator.send_player_action(human,action_name,null)
