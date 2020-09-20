extends "res://src/Character/tasks/NoLimitTask.gd"
class_name GetCommunicationTarget

#获取通讯录目标
func active():
	.active()
	
	

#	self.action_target = human.get_target()
#	if not action_target:
#		goal_status = STATE.GOAL_FAILED
#		return 
#
#	if not human.is_interaction_distance(action_target):
#		goal_status = STATE.GOAL_FAILED
#		return
#
#	status_recover = true
	goal_status = STATE.GOAL_COMPLETED
