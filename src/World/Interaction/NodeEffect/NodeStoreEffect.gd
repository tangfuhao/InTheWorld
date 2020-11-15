class_name NodeStoreEffect
var node_name
var store_node setget set_store_name
var sotre_node_name

func set_store_name(_name):
	store_node = _name
	var objecet_regex = RegEx.new()
	objecet_regex.compile("\\$\\{(.+?)\\}")
	var node_find_result_arr = objecet_regex.search_all(store_node)
	if node_find_result_arr:
		for node_match_item in node_find_result_arr:
			sotre_node_name = node_match_item.get_string(1)
			return 

func _process(_delta,_param_accessor):
	var node = _param_accessor.get_node_ref(node_name)
	var be_store_node = _param_accessor.get_node_ref(sotre_node_name)
	if node.storage_layer.store(be_store_node):
		be_store_node.notify_storage_dependency_change()

