#属性管理
extends Node2D
class_name PlayerParam

#var param_arr := []
var param_dic := {}

signal params_value_update(_param_key,_param_value)



func _process(delta):
	#更新自定义属性
	for item in param_dic.values():
		item._process(delta)


func set_value(_key,_value):
	if param_dic.has(_key):
		var param_model = param_dic[_key]
		param_model.value = _value
		emit_signal("params_value_update",_key,param_model.value)
	else:
		assert(_value is ComomStuffParam)
		param_dic[_key] = _value
#		param_arr.push_back(_value)
		emit_signal("params_value_update",_key,_value.value)

func get_value(_key):
	if param_dic.has(_key):
		return param_dic[_key]
	return null

