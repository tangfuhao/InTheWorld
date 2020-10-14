class_name PlayerParam

var paramDic = {}
var origin_paramDic = {}

signal params_value_update(_param_key,_param_value)

func setup(_player):
	origin_paramDic["攻击"] = 1
	origin_paramDic["防御"] = 2
	


func set_value(_key,_value):
	if not paramDic.has(_key) or paramDic[_key] != _value:
		paramDic[_key] = int(_value)
		emit_signal("params_value_update",_key,get_value(_key))

func get_value(_key):
	var value = 0
	
	if paramDic.has(_key):
		value = value + paramDic[_key]
	
	if origin_paramDic.has(_key):
		value = value + origin_paramDic[_key]
	
	return value


func get_params() -> Dictionary:
	var compose_params = {}
	for item in origin_paramDic.keys():
		compose_params[item] = get_value(item)
		
	for item in paramDic:
		if not compose_params.has(item):
			compose_params[item] = get_value(item)
	return compose_params
