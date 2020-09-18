extends Node
#全局消息产生器
signal message_dispatch

enum MessageType { execute_action, stop_action, find_player_in_vision,lost_player_in_vision,find_in_vision,lost_in_vision,
location }


func create_common_message(_player,_type):
	var message_dic := {}
	message_dic["timestamp"] = OS.get_system_time_secs()
	message_dic["player"] = _player.node_name
	message_dic["type"] = _type
	return message_dic
	
func send_message_to_subscriber(_message_dic):
	emit_signal("message_dispatch",_message_dic)

#角色执行动作
func send_player_action(_player,_action,_target):
	if not _player: return 
	
	var message_dic = create_common_message(_player,"execute_action")
	message_dic["value"] = _action
	if _target and _target is String:
		message_dic["target"] = _target
	elif _target:
		message_dic["target"] = _target.node_name
	
	send_message_to_subscriber(message_dic)
	

#角色停止执行行为
func send_player_stop_action(_player,_action,_target):
	if not _player: return 
	
	var message_dic = create_common_message(_player,"stop_action")
	message_dic["value"] = _action
	if _target and _target is String:
		message_dic["target"] = _target
	elif _target:
		message_dic["target"] = _target.node_name
	
	send_message_to_subscriber(message_dic)

#角色视线检测
func send_player_find_player_in_vision(_player,_target):
	if not _player: return 
	
	var message_dic = create_common_message(_player,"find_player_in_vision")
	message_dic["target"] = _target.node_name
	send_message_to_subscriber(message_dic)
	
func send_player_lost_player_in_vision(_player,_target):
	if not _player: return 
	
	var message_dic = create_common_message(_player,"lost_player_in_vision")
	message_dic["target"] = _target.node_name
	send_message_to_subscriber(message_dic)
	
func send_player_find_stuff_in_vision(_player,_target):
	if not _player: return 
	
	var message_dic = create_common_message(_player,"find_in_vision")
	message_dic["target"] = _target.node_name
	send_message_to_subscriber(message_dic)
	
func send_player_lost_stuff_in_vision(_player,_target):
	if not _player: return 
	
	var message_dic = create_common_message(_player,"lost_in_vision")
	message_dic["target"] = _target.node_name
	send_message_to_subscriber(message_dic)

#角色位置变化
func send_player_location_change(_player,_location):
	if not _player: return 
	
	var message_dic = create_common_message(_player,"location")
	message_dic["target"] = _location
	send_message_to_subscriber(message_dic)
	
#角色认知更改认知
func send_player_world_status_change(_player,_world_status,_value):
	if not _player: return 
	
	var message_dic = create_common_message(_player,"world_status_change")
	message_dic["target"] = _world_status
	message_dic["value"] = _value
	
	send_message_to_subscriber(message_dic)

#最高优先级动机值变更
func send_highest_priority_motivation(_player,_motivation):
	if not _player: return 

	var message_dic = create_common_message(_player,"highest_priority_motivation")
	message_dic["target"] = _motivation.motivation_name
	message_dic["value"] = _motivation.motivation_value
	
	send_message_to_subscriber(message_dic)

#角色动机值改变	
func send_player_motivation_value_change(_player,_motivation):
	if not _player: return 
	var message_dic = create_common_message(_player,"motivation_change")
	message_dic["target"] = _motivation.motivation_name
	message_dic["value"] = _motivation.motivation_value
	
	send_message_to_subscriber(message_dic)

#角色目标切换
func send_player_target_change(_player,_target):
	var message_dic = create_common_message(_player,"target_change")
	message_dic["target"] = _target.node_name
	
	send_message_to_subscriber(message_dic)

func send_player_strategy_plan_succuss(_player,_strategy_chain):
	var strategy_record_arr =  _strategy_chain.strategy_record_arr
	for item in strategy_record_arr:
		var message_dic = create_common_message(_player,"strategy_plan_succuss")
		message_dic["target"] = item
		send_message_to_subscriber(message_dic)

func send_player_strategy_plan_fail(_player,_strategy_chain):
	var strategy_record_arr =  _strategy_chain.strategy_record_arr
	for item in strategy_record_arr:
		var message_dic = create_common_message(_player,"strategy_plan_fail")
		message_dic["target"] = item
		send_message_to_subscriber(message_dic)




#角色策略规划
func send_player_strategy_plan(_player,_strategy_plan_path,_plan_result):
	var message_dic = create_common_message(_player,"strategy_plan")
	message_dic["target"] = _strategy_plan_path
	message_dic["value"] = _plan_result
	
	send_message_to_subscriber(message_dic)

#喜爱值改变
func send_player_lover_value_change(_player,_target,_lover_value):
	var message_dic = create_common_message(_player,"lover_value_change")
	message_dic["target"] = _target.node_name
	message_dic["value"] = _lover_value
	
	send_message_to_subscriber(message_dic)

func send_player_lover_effect(_player,_target,_effect_value,_action):
	var message_dic
	if _effect_value > 0:
		message_dic = create_common_message(_player,"lover_increase_effect")
	else:
		message_dic = create_common_message(_player,"lover_decrease_effect")
		
	message_dic["target"] = _target.node_name
	message_dic["value"] = _action
	
	send_message_to_subscriber(message_dic)
