extends "res://src/character/tasks/NoLimitTask.gd"
class_name Punch

var action_target

func active():
	.active()
	if human:
		action_target = human.get_target()
		if action_target:
			excute_action = true
			GlobalMessageGenerator.send_player_action(human,action_name,action_target)
			var hit_box = human.hit_box
			hit_box.set_deferred("monitorable",true)			
			return 
	goal_status = STATE.GOAL_FAILED

func terminate():
	if human:
		var hit_box = human.hit_box
		hit_box.set_deferred("monitorable",false)


func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,action_target)