class_name Task

#调用者
var human
#行为参数组
var params:Array setget set_params
#行为名
var action_name
#带参数的完整行为名
var full_action
var full_target

#是否恢复
var status_recover = false

#是否执行了行为
var excute_action = false
#行为的目标
var action_target setget set_action_target

enum STATE {GOAL_ACTIVE, GOAL_INACTIVE, GOAL_COMPLETED, GOAL_FAILED, GOAL_ACTIVE_SKIP}

var goal_status = STATE.GOAL_ACTIVE

func init(_action_name,_human,_params) ->void:
	action_name = _action_name
	full_action = action_name
	human = _human
	if _params:
		self.params = _params

func is_valid():
	return human != null
	
func active() ->void:
	pass

func process(_delta: float):
	action_execute_notity_to_message()
	return goal_status
	
func terminate() ->void:
	action_stop_execute_notify_to_message()



func set_action_target(_action_target):
	action_target = _action_target
	full_target = action_target

func set_params(_params):
	if _params is String:
		params = _params.split("-")
	elif _params is Array:
		params = _params
	
func get_params():
	if params and not params.empty():
		return params[0]
	else:
		return null

func get_index_params(_index):
	return params[_index]



func action_execute_notity_to_message():
	if not excute_action and (goal_status == STATE.GOAL_ACTIVE or goal_status == STATE.GOAL_COMPLETED):
		excute_action = true

#		human.notify_action(action_name,true)
		GlobalMessageGenerator.send_player_action(human,full_action,full_target)

func action_stop_execute_notify_to_message():
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,full_action,full_target)
	


