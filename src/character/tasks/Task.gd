class_name Task

var human:Player
var params

enum STATE {GOAL_ACTIVE, GOAL_INACTIVE, GOAL_COMPLETED, GOAL_FAILED}

func init(_human:Player,_params) ->void:
	human = _human
	if _params:
		params = _params
	
func active() ->void:
	pass

func process(_delta: float):
	return STATE.GOAL_COMPLETED
	
func terminate() ->void:
	pass
