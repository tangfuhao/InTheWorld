class_name MotivationModel
var motivation_name:String
var listner_status_name:String
var active_gain:float = 0
var motivation_value:float = 0 setget set_motivation_value
var is_active = false


signal motivation_active_change(motivation)
signal motivation_value_change(motivation)

#更新状态值
func update_status_value(status):
	var value = status.status_value
	#激活
	if value < 0.8:
		#加入增益
		self.motivation_value = value + active_gain
	else:
		self.motivation_value = value

func set_motivation_value(value):
	var is_active_temp = is_active
	motivation_value = value
	if motivation_value < 0 : motivation_value = 0
	is_active = motivation_value < 0.8
	# print(motivation_name,"的值更新为:",motivation_value)
	
	#激活状态改变
	if is_active_temp != is_active:
		# if is_active :
		# 	print(motivation_name,"改变为:激活")
		# else:
		# 	print(motivation_name,"改变为:未激活")
		emit_signal("motivation_active_change",self)
		
	emit_signal("motivation_value_change",self)