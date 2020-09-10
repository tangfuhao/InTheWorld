extends Node
#全局消息产生器

signal message_dispatch

var id_index = 0
func pop_id_index():
	id_index = id_index + 1
	return "-%d"%id_index

#角色执行动作
func send_player_action(_player,_action,_target):
	var message_dic := {}
	message_dic["timestamp"] = OS.get_system_time_secs()
	message_dic["player"] = _player.node_name
	message_dic["type"] = "execute_action"
	message_dic["value"] = _action
	if _target:
		message_dic["target"] = _target.node_name
	
	emit_signal("message_dispatch",message_dic)

#角色视线检测
func send_player_find_player_in_vision(_player,_target):
	var message_dic := {}
	message_dic["timestamp"] = OS.get_system_time_secs()
	message_dic["player"] = _player.node_name
	message_dic["type"] = "find_in_vision"
	message_dic["target"] = _target.node_name
	emit_signal("message_dispatch",message_dic)
	
func send_player_lost_player_in_vision(_player,_target):
	var message_dic := {}
	message_dic["timestamp"] = OS.get_system_time_secs()
	message_dic["player"] = _player.node_name
	message_dic["type"] = "lost_in_vision"
	message_dic["target"] = _target.node_name
	emit_signal("message_dispatch",message_dic)
	
func send_player_find_stuff_in_vision(_player,_target):
	var message_dic := {}
	message_dic["timestamp"] = OS.get_system_time_secs()
	message_dic["player"] = _player.node_name
	message_dic["type"] = "find_in_vision"
	message_dic["target"] = _target.node_name
	emit_signal("message_dispatch",message_dic)
	
func send_player_lost_stuff_in_vision(_player,_target):
	var message_dic := {}
	message_dic["timestamp"] = OS.get_system_time_secs()
	message_dic["player"] = _player.node_name
	message_dic["type"] = "lost_in_vision"
	message_dic["target"] = _target.node_name
	emit_signal("message_dispatch",message_dic)

#角色位置变化
func send_player_location_change(_player,_location):
	var message_dic := {}
	message_dic["timestamp"] = OS.get_system_time_secs()
	message_dic["player"] = _player.node_name
	message_dic["type"] = "location"
	message_dic["target"] = _location
	
	emit_signal("message_dispatch",message_dic)
	
#角色认知更改认知
func send_player_world_status_change(_player,_world_status,_value):
	var message_dic := {}
	message_dic["timestamp"] = OS.get_system_time_secs()
	message_dic["player"] = _player.node_name
	message_dic["type"] = "world_status_change"
	message_dic["target"] = _world_status
	message_dic["value"] = _value
	
	emit_signal("message_dispatch",message_dic)
	
#角色动机值改变	
func send_player_motivation_value_change(_player,_motivation,_value):
	var message_dic := {}
	message_dic["timestamp"] = OS.get_system_time_secs()
	message_dic["player"] = _player.node_name
	message_dic["type"] = "motivation_change"
	message_dic["target"] = _motivation
	message_dic["value"] = _value
	
	emit_signal("message_dispatch",message_dic)

#角色目标切换
func send_player_target_change(_player,_target):
	var message_dic := {}
	message_dic["timestamp"] = OS.get_system_time_secs()
	message_dic["player"] = _player.node_name
	message_dic["type"] = "target_change"
	message_dic["target"] = _target.node_name
	
	emit_signal("message_dispatch",message_dic)
	

#角色策略规划
func send_player_strategy_plan():
	pass

#喜爱值改变
func send_player_lover_value_change(_player,_target,_lover_value):
	var message_dic := {}
	message_dic["timestamp"] = OS.get_system_time_secs()
	message_dic["player"] = _player.node_name
	message_dic["type"] = "lover_value_change"
	message_dic["target"] = _target.node_name
	message_dic["value"] = _lover_value
	
	emit_signal("message_dispatch",message_dic)
