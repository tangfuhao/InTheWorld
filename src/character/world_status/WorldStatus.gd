extends Node2D
class_name WorldStatus
#认知
var world_status_dic:Dictionary = {}
#signal world_status_change(status)
signal world_status_change

var player_detection_zone:VisionSensor

func setup():
	world_status_dic["可以移动"] = true
	world_status_dic["周围有其他人"] = false
	world_status_dic["周围没有其他人"] = true
	world_status_dic["其他人没有武器"] = true
	world_status_dic["受到攻击"] = false
	world_status_dic["不受攻击十秒"] = true
	world_status_dic["未躲入十秒"] = true
	world_status_dic["没有远程武器"] = true
	world_status_dic["有远程武器"] = false
	world_status_dic["不在近战攻击范围"] = true
	world_status_dic["不在远程攻击范围"] = true


	
	
	player_detection_zone = owner.player_detection_zone
	player_detection_zone.connect("player_in_vision",self,"player_num_change_in_world_status")
	player_detection_zone.connect("player_out_vision",self,"player_num_change_in_world_status")
	
	owner.control_node.connect("to_target_distance_update",self,"to_target_distance_update")
	
func to_target_distance_update(_distance):
	world_status_dic["不在近战攻击范围"] = _distance > 20
	world_status_dic["不在远程攻击范围"] = _distance > 200
	
func player_num_change_in_world_status():
	var target = player_detection_zone.get_recent_target("其他人")
	var has_other_people = target != null

	if world_status_dic["周围有其他人"] != has_other_people:
		world_status_dic["周围有其他人"] = has_other_people
		world_status_dic["周围没有其他人"] = !has_other_people
#		emit_signal("world_status_change",["周围有其他人",has_other_people])
#		emit_signal("world_status_change",["周围没有其他人",!has_other_people])
		emit_signal("world_status_change")
		
#	if has_other_people:
#		get_recently_see_people_arr()
# 	else:
#		world_status_dic["其他人没有武器"] = true
		


func meet_condition(_condition_item) -> bool :
	if world_status_dic.has(_condition_item):
		return world_status_dic[_condition_item]
	return false
