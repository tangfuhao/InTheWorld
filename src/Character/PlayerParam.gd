#属性管理
extends Node2D
class_name PlayerParam
var param_arr := []
var param_dic := {}

signal params_value_update(_param_key,_param_value)

func _ready():
	for index in range(0,10):
		var item := ParamItem.new("属性",index)
		param_arr.push_back(item)
		param_dic[item.name] = item

func set_value(_key,_value):
	if not param_dic.has(_key) or param_dic[_key] != _value:
		param_dic[_key] = _value
		emit_signal("params_value_update",_key,_value)

func get_value(_key):
	if param_dic.has(_key):
		return param_dic[_key]
	return 0

