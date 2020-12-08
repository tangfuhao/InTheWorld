extends Node

#不重复的方式加入值
func add_item_to_arr_no_repeat(_arr:Array,_value):
	if _arr.has(_value):
		return 
	_arr.push_back(_value)
	
func remove_item_from_arr(_arr:Array,_value):
	if _arr.has(_value):
		_arr.erase(_value)


func get_dic_item_by_key_from_dic(_dic,_key) -> Dictionary:
	if _dic.has(_key):
		return _dic[_key]
	_dic[_key] = {}
	return _dic[_key]
	
func get_arr_item_by_key_from_dic(_dic,_key) -> Array:
	if _dic.has(_key):
		return _dic[_key]
	_dic[_key] = []
	return _dic[_key]

