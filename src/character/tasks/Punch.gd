extends "res://src/character/tasks/NoLimitTask.gd"
class_name Punch

func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			GlobalMessageGenerator.send_player_action(human,action_name,target)
			var hit_box = human.hit_box
			hit_box.set_deferred("monitorable",true)			
			return 
	goal_status = STATE.GOAL_FAILED

func terminate():
	if human:
		var hit_box = human.hit_box
		hit_box.set_deferred("monitorable",false)
