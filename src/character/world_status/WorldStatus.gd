extends Node2D
class_name WorldStatus

#认知
var world_status_dic:Dictionary = {}
var control_node


signal world_status_change(_world_status_item)



func setup(_control_node):
	control_node = _control_node
	world_status_dic["可以移动"] = true
	world_status_dic["周围没有其他人"] = true
	world_status_dic["其他人没有武器"] = true
	
	# world_status_dic["受到攻击"] = false
	# world_status_dic["不受攻击十秒"] = true
	
	world_status_dic["未躲入十秒"] = true

	# world_status_dic["不在近战攻击范围"] = true
	# world_status_dic["不在远程攻击范围"] = true
	# world_status_dic["在近战攻击范围"] = false
	# world_status_dic["在远程攻击范围"] = false

	# world_status_dic["周围有人在喝酒"] = false
	# world_status_dic["周围有人在聊天"] = false
	world_status_dic["淋浴间可用"] = false
#	world_status_dic["淋浴间被占用"] = false
#	world_status_dic["化身位置"] = "空地"
#	world_status_dic["非常困"] = false
	
#	world_status_dic["看到喜欢的人"] = false
#	world_status_dic["周围只有喜欢的人"] = false
#	world_status_dic["看到喜欢的人没穿衣服"] = false
#	world_status_dic["和喜欢的人在床上"] = false
#	world_status_dic["周围是黑的"] = false
#	world_status_dic["拥有:可弹情歌的"] = false
#	world_status_dic["拥有:是流体的"] = false
#	world_status_dic["没有远程武器"] = true
#	world_status_dic["有远程武器"] = false



func set_world_status(_world_status_item,_status_value):
	if world_status_dic.has(_world_status_item):
		var old_status_value = world_status_dic[_world_status_item]
		if old_status_value != _status_value:
			world_status_dic[_world_status_item] = _status_value
			print(control_node.player_name,"的认知:",_world_status_item," 改变为:",String(_status_value))
			emit_signal("world_status_change",_world_status_item)
	else:
		world_status_dic[_world_status_item] = _status_value
		if _status_value:
			print(control_node.player_name,"的认知:",_world_status_item," 改变为:",String(_status_value))
			emit_signal("world_status_change",_world_status_item)

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
		print(control_node.player_name,":不存在的认知:",condition_item_name," 默认返回false")
		return false



