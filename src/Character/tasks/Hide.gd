extends "res://src/character/tasks/Task.gd"
class_name Hide


var hide_record_start_time 
var world_status:WorldStatus


#获取目标任务
func active():
	.active()
	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return 

	if not human.is_interaction_distance(action_target):
		goal_status = STATE.GOAL_FAILED
		return 

	human.global_position.x = action_target.global_position.x
	human.global_position.y = action_target.global_position.y
	human.set_collision_layer_bit(1,false)
	hide_record_start_time = 10
	human.notify_disappear()

	
				

func process(_delta: float):
	.process(_delta)
	if not action_target:
		goal_status = STATE.GOAL_FAILED

	if goal_status != STATE.GOAL_ACTIVE:
		return goal_status

		

	hide_record_start_time = hide_record_start_time - _delta
	if hide_record_start_time < 0:
		var world_status = human.cpu.world_status
		world_status.world_status_dic["未躲入十秒"] = false


	return goal_status

func terminate():
	.terminate()

	human.set_collision_layer_bit(1,true)


	var world_status = human.cpu.world_status
	world_status.world_status_dic["未躲入十秒"] = true


