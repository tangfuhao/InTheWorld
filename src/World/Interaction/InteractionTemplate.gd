#作用的生成模板
class_name InteractionTemplate
const interaction_implement_scene = preload("res://src/World/Interaction/InteractionImplement.tscn")


#限制的条件
class IneractionRestrictCondition:
	var restrict_mode
	var node_name_in_interaction
	func _init(_restrict_mode,_restrict_node_name):
		restrict_mode = _restrict_mode
		node_name_in_interaction = _restrict_node_name
	
	func traverse_bind_node(_node,_node_arr:Array):
		var bind_object_list = _node.bind_layer.get_children()
		for item in bind_object_list:
			if not _node_arr.has(item):
				_node_arr.push_back(item)
			traverse_bind_node(item,_node_arr)

	func traverse_store_node(_node,_node_arr:Array):
		var store_object_list = _node.storage_layer.get_children()
		for item in store_object_list:
			if not _node_arr.has(item):
				_node_arr.push_back(item)
			traverse_store_node(item,_node_arr)
		
		
	func limit_node(_node)->Array:
		var node_arr := []
		if restrict_mode == "can_interact":
			traverse_bind_node(_node,node_arr)
			
			for item in _node.interactive_object_list:
				if not node_arr.has(item):
					node_arr.push_back(item)
		elif restrict_mode == "is_binding":
			node_arr = _node.bind_layer.get_children()
		elif restrict_mode == "is_storing":
			node_arr = _node.storage_layer.get_children()
		elif restrict_mode == "is_colliding":
			node_arr = _node.collision_object_arr
		elif restrict_mode == "is_affiliation":
			traverse_bind_node(_node,node_arr)
			var store_node_arr := []
			traverse_store_node(_node,store_node_arr)
			for item in store_node_arr:
				if not node_arr.has(item):
					node_arr.push_back(item)

			
			
		
		
		
		return node_arr

#节点匹配项
class InteractionNodeMatching:
	var node_name_in_interaction
	var node_type
	
	#限制范围的节点条件
	var restrict_node_condition := []
	
	#加入限制节点的条件
	func add_restrict_node_condition(_restrict_mode,_restrict_node_name):
		var restrict_condition = IneractionRestrictCondition.new(_restrict_mode,_restrict_node_name)
		restrict_node_condition.push_back(restrict_condition)
	
	func get_restrict_node_condition():
		return restrict_node_condition




var name
var type
var duration
var child_interaction_arr:Array
var parant_interaction

var conditions_arr := []

#名称-类型
var node_matching := []


#影响数组
var active_execute := []
var process_execute := []
var terminate_execute := []
var break_execute := []

#监听解析 节点名  监听信号
var update_condition_by_listening_node_signal_dic := {}
#确定属性
var update_condition_by_listening_node_value_dic := {}
#确定交互
var update_condition_by_listening_node_interaction_dic := {}
#确定碰撞
var update_condition_by_listening_node_cllision_dic := {}






func _init(_interaction_type,_interaction_name,_interaction_duration):
	type = _interaction_type
	name = _interaction_name
	duration = _interaction_duration

#新增节点配对
func add_node_matching(_node_name,_node_type):
	if name == "拿起物品":
		print("sdasd")
	var node_matching_item = InteractionNodeMatching.new()
	node_matching_item.node_name_in_interaction = _node_name
	node_matching_item.node_type = _node_type
	node_matching.push_back(node_matching_item)

func get_node_matchings():
	return node_matching

#根据node指代名 获取 node的匹配项
func find_node_matching(_node_name_in_interaction:String)->InteractionNodeMatching:
	for item in node_matching:
		if item.node_name_in_interaction == _node_name_in_interaction:
			return item
	assert(false)
	return null
	
func add_condition_item(item):
	conditions_arr.push_back(item)
	parse_condition_to_set_listening_content(item)
	parse_condition_for_restrict_node(item)
	


#根据条件 限制节点范围
func parse_condition_for_restrict_node(_condition_item):
	var function_regex = DataManager.function_regex
	var objecet_regex = DataManager.objecet_regex
	var result_arr = function_regex.search_all(_condition_item)
	if result_arr:
		for match_item in result_arr:
			var full = match_item.get_string(0)
			var group = match_item.get_string(1)
			var function_params = Array(group.split(","))
			var function_name = function_params.pop_front()
			if function_name == "can_interact" or function_name == "is_binding" or function_name == "is_storing" or function_name == "is_colliding" or function_name == "is_affiliation":
				var node_name = function_params.pop_front()
				node_name = extract_node_name(objecet_regex,node_name)
				var target_node_name = function_params.pop_front()
				target_node_name = extract_node_name(objecet_regex,target_node_name)
				var node_match_item:InteractionNodeMatching = find_node_matching(node_name)
				node_match_item.add_restrict_node_condition(function_name,target_node_name)

#根据条件 解析需要监听节点的数据
func parse_condition_to_set_listening_content(item):
	var function_regex = DataManager.function_regex
	var objecet_regex = DataManager.objecet_regex
	
	var result_arr = objecet_regex.search_all(item)
	if result_arr:
		for match_item in result_arr:
			var node_param = match_item.get_string(1)
			var find_index = node_param.find("[")
			if find_index != -1:
				var string_len = node_param.length()
				var node_name = node_param.substr(0,find_index)
				var node_param_name = node_param.substr(find_index+1,string_len - find_index - 2)
				var node_lisntening_param_value_arr = CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_value_dic,node_name)
				if node_param_name == "node":
					print("####",node_param_name)
				CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_param_value_arr,node_param_name)

			
	result_arr = function_regex.search_all(item)
	if result_arr:
		for match_item in result_arr:
			var full = match_item.get_string(0)
			var group = match_item.get_string(1)
			var function_params = Array(group.split(","))
			var function_name = function_params.pop_front()
			if function_name == "can_interact":
				var node_name = function_params.pop_front()
				node_name = extract_node_name(objecet_regex,node_name)
				var target_node_name = function_params.pop_front()
				target_node_name = extract_node_name(objecet_regex,target_node_name)
				
				var node_lisntening_interaction_arr = CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_interaction_dic,node_name)
				CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_interaction_arr,target_node_name)
				CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_interaction_arr,target_node_name)
				
				node_lisntening_interaction_arr = CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_interaction_dic,target_node_name)
				CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_interaction_arr,node_name)
				CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_interaction_arr,node_name)
			elif function_name == "is_binding":
				for node_name in function_params:
					node_name = extract_node_name(objecet_regex,node_name)
					var node_lisntening_signal_arr = CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_signal_dic,node_name)
					CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_signal_arr,"node_binding_dependency_change")

			elif function_name == "is_storing":
				for node_name in function_params:
					node_name = extract_node_name(objecet_regex,node_name)
					var node_lisntening_signal_arr = CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_signal_dic,node_name)
					CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_signal_arr,"node_storege_dependency_change")

			elif function_name == "is_colliding":
				var node_name = function_params.pop_front()
				node_name = extract_node_name(objecet_regex,node_name)
				var target_node_name = function_params.pop_front()
				target_node_name = extract_node_name(objecet_regex,target_node_name)
				
				var node_lisntening_collision_arr = CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_cllision_dic,node_name)
				CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_collision_arr,target_node_name)
				CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_collision_arr,target_node_name)
				
				node_lisntening_collision_arr = CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_cllision_dic,target_node_name)
				CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_collision_arr,node_name)
				CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_collision_arr,node_name)
				
				
			elif function_name == "affiliation_change":
				for node_name in function_params:
					node_name = extract_node_name(objecet_regex,node_name)
					var node_lisntening_signal_arr = CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_signal_dic,node_name)
					CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_signal_arr,"node_binding_dependency_change")
					CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_signal_arr,"node_storege_dependency_change")
			elif function_name == "is_value_change":
				var node_name = function_params.pop_front()
				node_name = extract_node_name(objecet_regex,node_name)
				var node_param_name = function_params.pop_front()
				var node_lisntening_param_value_arr = CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_value_dic,node_name)
				if node_param_name == "node":
					print("####",node_param_name)
				CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_param_value_arr,node_param_name)
			elif function_name == "num_of_parent_affiliation":
				for node_name in function_params:
					node_name = extract_node_name(objecet_regex,node_name)
					var node_lisntening_signal_arr = CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_signal_dic,node_name)
					CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_signal_arr,"node_add_to_main_scene")
					CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_signal_arr,"node_remove_to_main_scene")
			elif function_name == "num_of_colliding_objects":
				for node_name in function_params:
					node_name = extract_node_name(objecet_regex,node_name)
					var node_lisntening_signal_arr = CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_cllision_dic,node_name)
					CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_signal_arr,"node_collision_add_object")
					CollectionUtilities.add_item_to_arr_no_repeat(node_lisntening_signal_arr,"node_collision_remove_object")

func extract_node_name(_regex,_node_expression):
	var result_arr = _regex.search_all(_node_expression)
	assert(result_arr.size() <= 1)
	if result_arr.size() == 1:
		var node_name = result_arr.pop_front().get_string(1)
		return node_name
	else:
		return null
	
	
#创建交互实例  通过传入的交互节点
func create_interaction(_node_pair_item:Dictionary):
	var interaction_implement = interaction_implement_scene.instance()
	interaction_implement.interaction_name = name
	interaction_implement.duration = duration
	interaction_implement.conditions_arr = conditions_arr
	interaction_implement.update_condition_by_listening_node_signal_dic = update_condition_by_listening_node_signal_dic
	interaction_implement.update_condition_by_listening_node_value_dic = update_condition_by_listening_node_value_dic
	interaction_implement.update_condition_by_listening_node_interaction_dic = update_condition_by_listening_node_interaction_dic
	interaction_implement.update_condition_by_listening_node_cllision_dic = update_condition_by_listening_node_cllision_dic
	
	interaction_implement.clone_data(_node_pair_item,active_execute,process_execute,terminate_execute,break_execute)
	return interaction_implement
