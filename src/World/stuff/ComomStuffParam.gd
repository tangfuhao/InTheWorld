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

var value setget set_value
var init_value
var max_value
var min_value
var transform:ParamTransform setget set_transform


func set_transform(_transform_value):
	transform = ParamTransform.new(_transform_value)

func set_value(_value):
	value = _value
	if max_value and value > max_value:
		value = max_value
	elif min_value and value < min_value:
		value = min_value


func _process(_detal):
	if transform:
		if not value:
			self.value = 0.0

		assert(value is String)
		assert(value is bool)
		self.value = value + transform.t(_detal)
