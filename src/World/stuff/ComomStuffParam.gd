#参数的定义
class_name ComomStuffParam

class ParamTransform:
	var transformByMinute := 0.0
	var transformBySec := 0.0
	
	func _init(_value:float):
		transformByMinute = _value
		transformBySec = _value / 60.0
	
	func t(_detal) -> float:
		return transformBySec * _detal

var name
var value setget set_value
var init_value
var max_value = null
var min_value = null
var transform:ParamTransform setget set_transform
var temp_detal = 0

signal param_item_value_change(_param_item)

func set_transform(_transform_value):
	transform = ParamTransform.new(_transform_value)

func set_value(_value):
	var temp_value = value
	value = _value
	if max_value != null and value > max_value:
		value = max_value
	elif min_value != null and value < min_value:
		value = min_value
	
	if typeof(value) != typeof(temp_value) or value != temp_value:
		#值改变  发送信号
		emit_signal("param_item_value_change",self)


func _process(_detal):
	temp_detal = temp_detal + _detal
	if temp_detal < 1:
		return 
	
	
	if transform:
		if not value:
			self.value = 0.0
		
		
		assert(not value is String)
		assert(not value is bool)
		self.value = value + transform.t(temp_detal)
	
	temp_detal = 0
