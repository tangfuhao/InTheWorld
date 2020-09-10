extends "res://src/character/tasks/Task.gd"
class_name Hide
var hide_record_start_time 

var world_status:WorldStatus

#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			if human.is_approach(target):
				human.global_position.x = target.global_position.x
				human.global_position.y = target.global_position.y
				human.set_collision_layer_bit(1,false)
				hide_record_start_time = 10
				human.notify_disappear()
				GlobalMessageGenerator.send_player_action(human,action_name,target)
				# print(human.player_name,"躲入"+target.stuff_name)
				return 

	goal_status = STATE.GOAL_FAILED
				

func process(_delta: float):
	if goal_status == STATE.GOAL_ACTIVE:
		hide_record_start_time = hide_record_start_time - _delta
		if hide_record_start_time < 0:
			var world_status = human.cpu.world_status
			world_status.world_status_dic["未躲入十秒"] = false

	return goal_status

func terminate():
	human.set_collision_layer_bit(1,true)
	var world_status = human.cpu.world_status
	world_status.world_status_dic["未躲入十秒"] = true


