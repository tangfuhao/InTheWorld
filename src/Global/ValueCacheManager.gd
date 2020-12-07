#全局属性值 缓存
extends Node


#对属性值的缓存
var value_cache_dic := {}
var value_change_cache_dic := {}



#被联系的对象 和 联系它的对象
var be_affiliation_node_dic := {}
var be_affiliation_node_change_dic := {}

func _process(delta):
	apply_change_cache()
	
#新增新的节点
func add_monitor_node(_node:Node2D):
	_node.connect("disappear_notify",self,"_on_node_disappear_notify")
	_node.connect("node_param_item_value_change",self,"_on_node_param_item_value_change")
	_node.connect("node_binding_to",self,"_on_node_binding_dependency_change")
	_node.connect("node_storage_to",self,"_on_node_storage_dependency_change")
	
#	var affiliation_node = _node.get_parent().get_parent()
#	be_affiliation_node_dic[_node] = affiliation_node


func _on_node_disappear_notify(_stuff):
	_stuff.disconnect("disappear_notify",self,"_on_node_disappear_notify")
	_stuff.disconnect("node_param_item_value_change",self,"_on_node_param_item_value_change")
	_stuff.disconnect("node_binding_to",self,"_on_node_binding_dependency_change")
	_stuff.disconnect("node_storage_to",self,"_on_node_storage_dependency_change")
	
	if value_change_cache_dic.has(_stuff):
		value_change_cache_dic.erase(_stuff)
		
	if value_cache_dic.has(_stuff):
		value_cache_dic.erase(_stuff)
		
	if be_affiliation_node_change_dic.has(_stuff):
		be_affiliation_node_change_dic.erase(_stuff)
	
	if be_affiliation_node_dic.has(_stuff):
		be_affiliation_node_dic.erase(_stuff)
	

func _on_node_param_item_value_change(_node,_param_item,_old_value,_new_value):
	if not value_cache_dic.has(_node):
		var node_param_dic = CollectionUtilities.get_dic_item_by_key_from_dic(value_cache_dic,_node)
		node_param_dic[_param_item] = _old_value
	else:
		var node_param_dic = value_cache_dic[_node]
		if not node_param_dic.has(_param_item):
			node_param_dic[_param_item] = _old_value
	
	var node_param_change_dic = CollectionUtilities.get_dic_item_by_key_from_dic(value_change_cache_dic,_node)
	node_param_change_dic[_param_item] = _param_item.value

func _on_node_binding_dependency_change(_node,_target):
	var affiliation_node = _node.get_parent().get_parent()
	be_affiliation_node_change_dic[_node] = affiliation_node
	
	

func _on_node_storage_dependency_change(_node,_target):
	var affiliation_node = _node.get_parent().get_parent()
	be_affiliation_node_change_dic[_node] = affiliation_node



#获取未更新前的联系状态
#TODO 有重复询问绑定问题  石块-1 石块-1
func get_affiliation(_key,_node1,_node2):
	if not be_affiliation_node_dic.has(_node2):
		var affiliation_node = _node2.get_parent().get_parent()
		be_affiliation_node_change_dic[_node2] = affiliation_node
		return false
	else:
		var old_parent = be_affiliation_node_dic[_node2]
		return old_parent == _node1


#获取未更新前的属性值
func get_value_param(_node,_node_parms):
	if not value_cache_dic.has(_node):
		var node_param_arr = CollectionUtilities.get_dic_item_by_key_from_dic(value_cache_dic,_node)
		node_param_arr[_node_parms] = _node_parms.value
	var node_param_cache_dic = value_cache_dic[_node]
	if not node_param_cache_dic.has(_node_parms):
		node_param_cache_dic[_node_parms] = _node_parms.value
	return node_param_cache_dic[_node_parms]
	
	
#将改变的缓存 同步到 最新数据
func apply_change_cache():
	for item in be_affiliation_node_change_dic.keys():
		be_affiliation_node_dic[item] = be_affiliation_node_change_dic[item]
	be_affiliation_node_change_dic.clear()

	for item in value_change_cache_dic.keys():
		var node_param_change_dic = value_change_cache_dic[item]
		var node_param_dic = CollectionUtilities.get_dic_item_by_key_from_dic(value_cache_dic,item)
		for node_param_item in node_param_change_dic.keys():
			node_param_dic[node_param_item] = node_param_change_dic[node_param_item]
	value_change_cache_dic.clear()


#某个条件满足 清理所有缓存
func clear_interaction_chache():
	be_affiliation_node_change_dic.clear()
	be_affiliation_node_dic.clear()
	value_change_cache_dic.clear()
	value_cache_dic.clear()
