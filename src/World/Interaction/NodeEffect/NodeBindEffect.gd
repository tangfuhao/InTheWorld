class_name NodeBindEffect
var node
var node_name
var bind_node setget set_bind_node
var bind_node_name

func set_bind_node(_name):
	bind_node = _name
	var objecet_regex = RegEx.new()
	objecet_regex.compile("\\$\\{(.+?)\\}")
	var node_find_result_arr = objecet_regex.search_all(bind_node)
	if node_find_result_arr:
		for node_match_item in node_find_result_arr:
			bind_node_name = node_match_item.get_string(1)
			return 


func _process(_delta,_param_accessor):
	var be_store_node = _param_accessor.get_node_ref(bind_node_name)
	node.bind_layer.bind(be_store_node)
