class_name NodeReleaseEffect
var node_name

var release_node setget set_release_node
var release_node_name

func set_release_node(_name):
	release_node = _name
	var objecet_regex = DataManager.objecet_regex
	var node_find_result_arr = objecet_regex.search_all(release_node)
	if node_find_result_arr:
		for node_match_item in node_find_result_arr:
			release_node_name = node_match_item.get_string(1)
			return 


func _process(_delta,_param_accessor):
	var node = _param_accessor.get_node_ref(node_name)

	var main_scence = node.game_wapper_ref.get_main_scence(node)
	var stuff_layer = main_scence.customer_node_group

	var node_ref = _param_accessor.get_node_ref(release_node_name)
	var target_global_position = node_ref.get_global_position()



	if node.storage_layer.is_store(node_ref) and node.storage_layer.un_store(node_ref):
		node_ref.notify_node_un_storage_to(node.storage_layer)

		#加入到场景
		add_to_main_scene(stuff_layer,node_ref,target_global_position)
		node_ref.notify_node_add_to_main_scene()
		
	elif node.bind_layer.is_bind(node_ref) and node.bind_layer.un_bind(node_ref):
		node_ref.notify_node_un_binding_to(node.bind_layer)

		#加入到场景
		add_to_main_scene(stuff_layer,node_ref,target_global_position)
		node_ref.notify_node_add_to_main_scene()
		
func add_to_main_scene(main_scence,stuff_node,position):
	main_scence.add_child(stuff_node)
	stuff_node.set_global_position(position)
	#TODO 链接地图
#	main_scence.binding_customer_node_item(stuff_node)
	
