extends Node2D
class_name WorldStatus

onready var hurt_time = $HurtTimer

#认知
var world_status_dic:Dictionary = {}
var control_node

signal world_status_change



func setup(_control_node):
	control_node = _control_node
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
	world_status_dic["在近战攻击范围"] = false
	world_status_dic["在远程攻击范围"] = false
	
	
	control_node.connect("package_item_change",self,"_on_character_player_package_item_change")
	control_node.connect("find_something",self,"_on_character_player_num_change_in_world_status")
	control_node.connect("un_find_something",self,"_on_character_player_num_change_in_world_status")
	
	control_node.connect("to_target_distance_update",self,"_on_character_to_target_distance_update")
	control_node.connect("be_hurt",self,"_on_character_be_hurt")
	
func _on_character_player_package_item_change(_item,_exist):
	var has_remote_weapons = world_status_dic["有远程武器"]
	if has_remote_weapons:
		if _exist == false && _item.has_attribute("可发射的"):
			var object = control_node.get_item_in_package("可发射的")
			if object == null:
				world_status_dic["有远程武器"] = false
				world_status_dic["没有远程武器"] = true
				emit_signal("world_status_change")
	else:
		if _exist && _item.has_attribute("可发射的"):
			world_status_dic["有远程武器"] = true
			world_status_dic["没有远程武器"] = false
			emit_signal("world_status_change")
		
	
func _on_character_be_hurt(area):
	var is_hurt_status = world_status_dic["受到攻击"]
	if hurt_time.is_stopped():
		hurt_time.start(10)
	else:
		hurt_time.stop()
		hurt_time.start(10)
	if is_hurt_status == false: 
		world_status_dic["受到攻击"] = true
		world_status_dic["不受攻击十秒"] = false
		print(control_node.player_name,"认知 受到攻击 改变")
		emit_signal("world_status_change")
	
	
	
func _on_character_to_target_distance_update(_distance):
	var is_no_melee_range = world_status_dic["不在近战攻击范围"]
	var is_no_remote_attak = world_status_dic["不在远程攻击范围"]

	var is_no_melee_range_new = _distance > 20
	var is_no_remote_attak_new = _distance > 200
	if is_no_melee_range != is_no_melee_range_new || is_no_remote_attak != is_no_remote_attak_new:
		world_status_dic["不在近战攻击范围"] = is_no_melee_range_new
		world_status_dic["不在远程攻击范围"] = is_no_remote_attak_new
		world_status_dic["在近战攻击范围"] = !is_no_melee_range_new
		world_status_dic["在远程攻击范围"] = !is_no_remote_attak_new
		print(control_node.player_name,"认知 攻击范围 改变")
		emit_signal("world_status_change")



	
func _on_character_player_num_change_in_world_status(_body):
	if _body is Player:
		var target = control_node.get_recent_target("其他人")
		var has_other_people = target != null

		if world_status_dic["周围有其他人"] != has_other_people:
			world_status_dic["周围有其他人"] = has_other_people
			world_status_dic["周围没有其他人"] = !has_other_people
			print(control_node.player_name,"认知 周围有其他人 改变")
			emit_signal("world_status_change")

func _on_HurtTimer_timeout():
	var is_hurt_status = world_status_dic["受到攻击"]
	if is_hurt_status: 
		world_status_dic["受到攻击"] = false
		world_status_dic["不受攻击十秒"] = true
		print(control_node.player_name,"认知 不受攻击十秒 改变")
		emit_signal("world_status_change")
		
		


func meet_condition(_condition_item) -> bool :
	if world_status_dic.has(_condition_item):
		return world_status_dic[_condition_item]
	return false



