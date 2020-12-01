#属性管理
extends Node2D
class_name PlayerParam

#var param_arr := []
var param_dic := {}
signal param_item_value_change(_param_item,_old_value,_new_value)
func _process(delta):
	#更新自定义属性
	for item in param_dic.values():
		item._process(delta)




func set_value(_key:String,_value:ComomStuffParam):
	if param_dic.has(_key):
		var param_model = param_dic[_key]
		param_model.disconnect("param_item_value_change",self,"on_param_item_self_value_change")

	_value.connect("param_item_value_change",self,"on_param_item_self_value_change")
	param_dic[_key] = _value
	emit_signal("param_item_value_change",_value,0,_value.value)

func get_value(_key) -> ComomStuffParam:
	if param_dic.has(_key):
		return param_dic[_key]
	return null

func has_param_item(_name):
	return param_dic.has(_name)

#属性的值更改通知
func on_param_item_self_value_change(_param_item,_old_value,_new_value):
	emit_signal("param_item_value_change",_param_item,_old_value,_new_value)

