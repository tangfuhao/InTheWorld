#发送消息
class_name NodeSendInfoToTargetEffect
var node_name

var send_info setget set_send_info
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

func set_send_info(_send_info):
	send_info = _send_info
	
					

func parse_node_name(_param_accessor):
	var objecet_regex = DataManager.objecet_regex
	var node_find_result_arr = objecet_regex.search_all(send_info)
	if node_find_result_arr:
		for node_match_item in node_find_result_arr:
			var origin_text = node_match_item.get_string(0)
			var node_param = node_match_item.get_string(1)
			var find_index = node_param.find("[")
			if find_index != -1:
				var string_len = node_param.length()
				var node_name = node_param.substr(0,find_index)
				var node_param_name = node_param.substr(find_index+1,string_len - find_index - 2)
				var node = _param_accessor.get_node_ref(node_name)
				var result = node.get_param_value(node_param_name)
				send_info = send_info.replace(origin_text,result)


func _process(_delta,_param_accessor):
	parse_node_name(_param_accessor)
	var node = _param_accessor.get_node_ref(node_name)
	var target_node = _param_accessor.get_node_ref(target_node_name)
	node.send_message(target_node,send_info)
	

