extends "res://src/character/tasks/NoLimitTask.gd"
class_name StruggleMind
func active() ->void:
	.active()
	if human:
		print(human.player_name,"纠结")
		human.set_status_value("爱情动机",0.9)
