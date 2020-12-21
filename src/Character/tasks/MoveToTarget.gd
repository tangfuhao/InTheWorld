#移动到目标
extends "res://src/Character/tasks/Task.gd"
class_name MoveToTarget

func active():
	.active()
	var target = human.target_system.get_recently_target()
	if not target:
		goal_status = STATE.GOAL_FAILED
		return 

	var move_interaction = human.get_running_interaction("移动")
	if not move_interaction:
		#创建交互
		move_interaction = MoveInteractionImplement.new()
		move_interaction.human = human
		human.add_and_connect_interaction_implement(move_interaction)

	move_interaction.connect("interaction_finish",self,"_on_interaction_finish")
	move_interaction.setup_target(target)


func terminate() ->void:
	.terminate()
	var move_interaction = human.get_running_interaction("移动")
	if move_interaction:
		human.break_interaction(move_interaction)
		
func _on_interaction_finish(_interaction):
	goal_status = STATE.GOAL_COMPLETED
