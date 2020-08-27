extends "res://src/character/tasks/Task.gd"
class_name ExamineElectricalPowerSystems
func active() ->void:
	if human:
		print(human.player_name,"检查电力系统")