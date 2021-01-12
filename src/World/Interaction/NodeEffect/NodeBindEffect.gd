class_name NodeBindEffect
var node_name
var bind_node setget set_bind_node
var bind_node_name

func set_bind_node(_name):
	bind_node = _name
	var objecet_regex = DataManager.objecet_regex
	var node_find_result_arr = objecet_regex.search_all(bind_node)
	if node_find_result_arr:
		for node_match_item in node_find_result_arr:
			bind_node_name = node_match_item.get_string(1)
			return 


func _process(_delta,_param_accessor):
	var node = _param_accessor.get_node_ref(node_name)
	var be_bind_node = _param_accessor.get_node_ref(bind_node_name)
	var main_scence = node.game_wapper_ref.get_main_scence(node)
	var stuff_layer = main_scence.customer_node_group
	var parent_node = be_bind_node.get_parent()
	


	if node.bind_layer.bind(be_bind_node):
		if parent_node:
			if parent_node == stuff_layer:
				be_bind_node.notify_node_remove_to_main_scene()
			else:
				be_bind_node.notify_node_un_binding_to(parent_node)

		be_bind_node.notify_node_binding_to(node.bind_layer)
