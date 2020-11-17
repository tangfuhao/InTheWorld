#发送消息
class_name NodeSendInfoToTargetEffect
var node_name

var send_info
var info_target setget set_info_target

var target_node_name

func set_info_target(_info_target):
	info_target = _info_target
	var objecet_regex = DataManager.objecet_regex
	var node_find_result_arr = objecet_regex.search_all(info_target)
	if node_find_result_arr:
		for node_match_item in node_find_result_arr:
			target_node_name = node_match_item.get_string(1)
			return 



func _process(_delta,_param_accessor):
	var node = _param_accessor.get_node_ref(node_name)
	var target_node = _param_accessor.get_node_ref(target_node_name)
	node.send_message(target_node,send_info)
	

