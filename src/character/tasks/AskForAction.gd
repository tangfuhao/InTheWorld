#请求动作许可
extends "res://src/character/tasks/Task.gd"
class_name AskForAction
func active() ->void:
	if human:
		print(human.player_name,"请求许可")