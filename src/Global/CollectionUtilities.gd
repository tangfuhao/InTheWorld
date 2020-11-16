extends Node

#不重复的方式加入值
func add_item_to_arr_no_repeat(_arr:Array,_value):
	if _arr.has(_value):
		return 
	_arr.push_back(_value)

#TODO 多次用到
func get_arr_value_from_dic(_type_stuff_dic:Dictionary,_item) -> Array:
	if not _type_stuff_dic.has(_item):
		_type_stuff_dic[_item] = []
	return _type_stuff_dic[_item]
