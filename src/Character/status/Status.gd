extends Node
class_name Status

#一分钟-更新状态值 可以修改快速看到状态值得改变
export var update_time = 5




#暂停时剩余的时间
var pause_left_time:float = 0
var statusDic:Dictionary = {}
var control_node


onready var updateTimer := $UpdaterTimer

signal status_value_update(status_model)



#更新时间到了之后 更新数值 并重新计时
func _on_UpdaterTimer_timeout():
	update_status()
	start_update()
	
func _on_status_model_value_update(_status_model):
	emit_signal("status_value_update",_status_model)


func setup(_control_node):
	control_node = _control_node
	statusDic = DataManager.get_player_data(control_node.player_name,"status")
	binding_status_listner_relative()
	start_update()


func pauseUpdate():
	pause_left_time = 0
	if not updateTimer.is_stopped():
		pause_left_time = updateTimer.time_left
		updateTimer.stop()
	
func start_update():
	if updateTimer.is_stopped():
		updateTimer.start(update_time - pause_left_time)
		pause_left_time = 0

func update_status():
	for status in statusDic.values():
		status.update_status(statusDic)

func set_status_value(_status_name,_status_value):
	var status_model = statusDic[_status_name]
	assert(status_model)
	status_model.set_status_value(_status_value)

func get_status_value(_status_name):
	var status_model = statusDic[_status_name]
	return status_model.status_value




func binding_status_listner_relative():
	for status in statusDic.values():
		status.binding_status_listner_relative(statusDic)
		status.connect("status_value_update",self,"_on_status_model_value_update")

