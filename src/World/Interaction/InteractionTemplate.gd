#作用的生成模板
class_name InteractionTemplate


const interaction_implement_scene = preload("res://src/World/Interaction/InteractionImplement.tscn")

var name
var type
var duration
var child_interaction_arr:Array
var parant_interaction

var conditions_arr := []

#名称-类型
var node_matching := {}
var node_match_name_arr := []

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
	
func add_condition_item(item):
	conditions_arr.push_back(item)
	parse_condition_to_set_listening_content(item)


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
					var node_lisntening_signal_arr = CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_signal_dic,node_name)
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
	
	
