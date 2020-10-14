class_name PlayerParam

var paramDic = {}


signal params_value_update(_param_key,_param_value)
signal equipment_change_update(_slot_name,_equipment_item)



func setup(_player):

	paramDic["攻击"] = 1
	paramDic["防御"] = 2
	



func set_value(_key,_value):
	if not paramDic.has(_key) or paramDic[_key] != _value:
		paramDic[_key] = int(_value)
		emit_signal("params_value_update",_key,get_value(_key))

func get_value(_key) -> int:
	if paramDic.has(_key):
		return paramDic[_key]
	return 0


func get_params() -> Dictionary:
	return paramDic
