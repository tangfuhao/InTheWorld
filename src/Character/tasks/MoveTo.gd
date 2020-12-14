extends "res://src/Character/tasks/NoLimitTask.gd"
class_name MoveTo

func active():
	.active()

	var move_interaction = human.get_running_interaction("移动")
	if not move_interaction:
		#创建交互
		move_interaction = MoveInteractionImplement.new()
		move_interaction.human = human
		human.add_and_connect_interaction_implement(move_interaction)
	
	
	move_interaction.connect("interaction_finish",self,"_on_interaction_finish")
	var target = get_index_params(0)
	move_interaction.setup_target(target)

func terminate() ->void:
	.terminate()
	var move_interaction = human.get_running_interaction("移动")
	if move_interaction:
		human.break_interaction(move_interaction)
		
func _on_interaction_finish(_interaction):
	goal_status = STATE.GOAL_COMPLETED
