class_name StatusModel
var status_value:float = 1 setget set_status_value
var status_name :String 
var status_conditions :Array

signal status_value_update

func set_status_value(value):
	status_value = value
	if status_value < 0:status_value = 0
	# print(status_name,"--被改为:",status_value)
	emit_signal("status_value_update",self)


#到了一分钟更新时间
func update_status(statusDic):
	for status_condition in status_conditions:
		if status_condition.is_active:
			status_condition.update_effects(statusDic)

#绑定监听的状态
func binding_status_listner_relative(statusDic):
	for status_condition in status_conditions:
		status_condition.binding_status_listner_relative(statusDic)
