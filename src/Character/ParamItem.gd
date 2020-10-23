#属性
class_name ParamItem
#属性的定义
class ParamItemConfig:
	var max_value
	var min_value
	var effect_arr

var name
var value
var config:ParamItemConfig


func _init(_name,_value):
	name = _name
	value = _value

func update():
	pass
