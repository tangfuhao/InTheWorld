class_name Task

var human:Player
var params



enum STATE {GOAL_ACTIVE, GOAL_INACTIVE, GOAL_COMPLETED, GOAL_FAILED}

var goal_status = STATE.GOAL_ACTIVE

func init(_human:Player,_params) ->void:
	human = _human
	if _params:
		params = _params
	
func active() ->void:
	pass

func process(_delta: float):
	return goal_status
	
func terminate() ->void:
	pass
