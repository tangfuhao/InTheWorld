extends "res://src/character/tasks/Task.gd"
class_name Hide
var hide_record_start_time 

var world_status:WorldStatus

var me_collision_layer = false
var is_hide = false
#获取目标任务
func active():
	.active()
	if human:
		world_status = human.cpu.world_status
		var target = human.get_target()
		if target:
			if human.is_approach(target):
				human.global_position.x = target.global_position.x
				human.global_position.y = target.global_position.y
				is_hide = true
				me_collision_layer =  human.get_collision_layer_bit(1)
				if me_collision_layer:
					human.set_collision_layer_bit(1,false)
				else:
					human.set_collision_layer_bit(2,false)
				hide_record_start_time = 10
				human.notify_disappear()
				print(human.player_name,"躲入"+target.stuff_name)
				

func process(_delta: float):
	if is_hide:
		hide_record_start_time = hide_record_start_time - _delta
		if hide_record_start_time < 0:
			world_status.world_status_dic["未躲入十秒"] = false

		return STATE.GOAL_ACTIVE
	else:
		return STATE.GOAL_FAILED

func terminate():
	if me_collision_layer:
		human.set_collision_layer_bit(1,true)
	else:
		human.set_collision_layer_bit(2,true)
	world_status.world_status_dic["未躲入十秒"] = true

