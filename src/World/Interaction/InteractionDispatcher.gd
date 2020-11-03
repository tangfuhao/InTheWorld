#被动作用调度器
extends Node2D
class_name InteractionDispatcher

#创建一个物品类型的引用
var type_stuff_dic = {}

#激活节点 对 交互的引用 值是 交互的数组
var active_node_to_interaction_dic := {}
#用到的节点类型的 交互模板
var use_node_type_to_interaction_template_dic := {}

# 有效 但条件失败的交互
var fail_interaction_arr := []


func _ready():
	make_stuff_type_tree()
	var god_interaction_arr = DataManager.get_interaction_arr_by_type("god")
	for item in god_interaction_arr:
		var node_match = item.node_matching
		#满足匹配关系的节点
		var match_node_arr = node_match(node_match)
		for match_node_pair_item in match_node_arr:
			#创建交互
			var interaction_implement = item.create_interaction(match_node_pair_item)
			#绑定关系
			for node_item in match_node_pair_item.values():
				var interaction_arr = get_arr_value_from_dic(active_node_to_interaction_dic,node_item)
				interaction_arr.push_back(interaction_implement)
			#加入场景
			add_child(interaction_implement)
		
		#绑定交互模板的关系
		for node_type_item in node_match.values():
			var interaction_template_arr = get_arr_value_from_dic(use_node_type_to_interaction_template_dic,node_type_item)
			interaction_template_arr.push_back(item)
	print("ss")

#组织节点类型
func make_stuff_type_tree():
	var root_node = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
	var stuff_layer = root_node.get_node("StuffLayer")
	var player_layer = root_node.get_node("PlayerLayer")
	var stuff_node_arr = stuff_layer.get_children()
	var player_node_arr = player_layer.get_children()
	type_stuff_dic["Player"] = player_node_arr
	
	for node_item in stuff_node_arr:
		var type_name = node_item.stuff_type_name
		var node_type_group = DataManager.get_node_type_group(type_name)
		for item in node_type_group:
			var node_arr = get_arr_value_from_dic(type_stuff_dic,item)
			node_arr.push_back(node_item)

func get_arr_value_from_dic(_type_stuff_dic,_item) -> Array:
	if not _type_stuff_dic.has(_item):
		_type_stuff_dic[_item] = []
	return _type_stuff_dic[_item]

func node_match(_node_match):
	var node_name_arr = _node_match.keys()
	var node_type_arr = _node_match.values()
	#类型集合的集合
	var node_type_arr_arr := []
	for item in node_type_arr:
		if not type_stuff_dic.has(item):
			return []

		var node_type_group = type_stuff_dic[item]
		if node_type_group.empty():
			return []
		
		node_type_arr_arr.push_back(node_type_group)

	#可以搭配的节点 组合
	#TODO 应该加入条件
	var result_arr := []
	node_match_iteration_collect(node_type_arr_arr,0,[],result_arr)
	
	
	var node_name_item_arr := []
	for node_arr_item in result_arr:
		var node_pair = {}
		var node_size = node_arr_item.size()
		for node_item_index in range(node_size):
			var node_name = node_name_arr[node_item_index]
			var node_item = node_arr_item[node_item_index]
			node_pair[node_name] = node_item
		node_name_item_arr.push_back(node_pair)
	
	return node_name_item_arr
	
	
func node_match_iteration_collect(_arr:Array,_index,_select_node_arr,_result_arr:Array):
	var arr_size = _arr.size()
	for i in range(arr_size):
		if i == _index:
			var child_arr = _arr[i]
			for node_item in child_arr:
				var select_node_arr = _select_node_arr.duplicate(true)
				select_node_arr.push_back(node_item)
				if i < arr_size - 1:
					node_match_iteration_collect(_arr,_index+1,select_node_arr,_result_arr)
				else:
					_result_arr.push_back(select_node_arr)