class_name NodeCreateEffect
var node_name
var create_name
#TODO 初始化 执行属性值
var params_arr


func _process(_delta,_param_accessor):
	var node = _param_accessor.get_node_ref(node_name)
	var create_params = Array(create_name.split(":"))
	var create_node_type = create_params.pop_front()
	var create_node_name = create_params.pop_front()
	var create_node = DataManager.instance_stuff_node(create_node_type)
	add_to_main_scene(node,create_node,node.get_global_position())
	#如果有引用名 就加到运行时缓存里
	if create_node_name:
		_param_accessor.set_runnig_node_ref(create_node,create_node_name)
	
	
func add_to_main_scene(node,stuff_node,position):
	var main_scence = node.get_node("/root/Island")
	main_scence.customer_node_group.add_child(stuff_node)
	stuff_node.set_global_position(position)
	main_scence.binding_customer_node_item(stuff_node)
	
