extends Node2D
class_name WorldStatus

#认知
var world_status_dic:Dictionary = {}
var control_node


signal world_status_change(_world_status_item)

var message_generator:MessageGenerator

func setup(_control_node,_message_generator):
	control_node = _control_node
	message_generator = _message_generator
	world_status_dic["可以移动"] = true
	world_status_dic["周围没有其他人"] = true
	world_status_dic["其他人没有武器"] = true
	world_status_dic["未躲入十秒"] = true
	world_status_dic["淋浴间可用"] = true




func set_world_status(_world_status_item,_status_value):
	if world_status_dic.has(_world_status_item):
		var old_status_value = world_status_dic[_world_status_item]
		if old_status_value != _status_value:
			world_status_dic[_world_status_item] = _status_value
			
			# print(control_node.player_name,"的认知:",_world_status_item," 改变为:",String(_status_value))
			emit_signal("world_status_change",_world_status_item)
			message_generator.send_player_world_status_change(control_node,_world_status_item,_status_value)
	else:
		world_status_dic[_world_status_item] = _status_value
		if _status_value:
			
			# print(control_node.player_name,"的认知:",_world_status_item," 改变为:",String(_status_value))
			emit_signal("world_status_change",_world_status_item)
			message_generator.send_player_world_status_change(control_node,_world_status_item,_status_value)

func meet_condition(_condition_item) -> bool :
	var condition_item_arr := Array(_condition_item.split(":"))
	var condition_item_name = condition_item_arr.pop_front()
	var condition_item_param = condition_item_arr.pop_front()
	if world_status_dic.has(condition_item_name):
		var value =  world_status_dic[condition_item_name]
		if value is String:
			return value == condition_item_param
		else:
			return value
	else:
		# print(control_node.player_name,":不存在的认知:",condition_item_name," 默认返回false")
		return false



