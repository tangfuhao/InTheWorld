class_name NodeReleaseEffect
var node_name

var release_node setget set_release_node
var release_node_name

func set_release_node(_name):
	release_node = _name
	var objecet_regex = RegEx.new()
	objecet_regex.compile("\\$\\{(.+?)\\}")
	var node_find_result_arr = objecet_regex.search_all(release_node)
	if node_find_result_arr:
		for node_match_item in node_find_result_arr:
			release_node_name = node_match_item.get_string(1)
			return 


func _process(_delta,_param_accessor):
	var node = _param_accessor.get_node_ref(node_name)
	var node_ref = _param_accessor.get_node_ref(release_node_name)
	var target_global_position = node_ref.get_global_position()
	if node.storage_layer.is_store(node_ref):
		
		node.storage_layer.un_store(node_ref)
		#加入到场景
		add_to_main_scene(node,node_ref,target_global_position)
	elif node.bind_layer.is_bind(node_ref):
		if node.bind_layer.un_bind(node_ref):
			#加入到场景
			add_to_main_scene(node,node_ref,target_global_position)
			node_ref.notify_binding_dependency_change()
		
func add_to_main_scene(node,stuff_node,position):
	var main_scence = node.get_node("/root/Island")
	main_scence.customer_node_group.add_child(stuff_node)
	stuff_node.set_global_position(position)
	main_scence.binding_customer_node_item(stuff_node)
	
