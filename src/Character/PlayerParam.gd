class_name PlayerParam

var paramDic = {}

signal params_value_update(_param_key,_param_value)

func setup(_player):
	paramDic["攻击"] = 1
	paramDic["防御"] = 2
	
	
	pass


func set_value(_key,_value):
	if not paramDic.has(_key) or paramDic[_key] != _value:
		paramDic[_key] = _value
		emit_signal("params_value_update",_key,_value)

func get_value(_key):
	return paramDic[_key]
