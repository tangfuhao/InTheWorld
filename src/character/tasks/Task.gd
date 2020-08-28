class_name Task

var human:Player
var params:Array setget set_params
var action_name


enum STATE {GOAL_ACTIVE, GOAL_INACTIVE, GOAL_COMPLETED, GOAL_FAILED}

var goal_status = STATE.GOAL_ACTIVE

func init(_action_name,_human,_params) ->void:
	action_name = _action_name
	human = _human
	if _params:
		self.params = _params
	
func active() ->void:
	pass

func process(_delta: float):
	return goal_status
	
func terminate() ->void:
	pass

func set_params(_params):
	params = _params.split("-")
	
func get_params():
	if params and not params.empty():
		return params[0]
	else:
		return null
	

func get_index_params(_index):
	return params[_index]
