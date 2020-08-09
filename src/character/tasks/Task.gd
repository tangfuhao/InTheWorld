class_name Task

var human:Player
var params:String

enum STATE {GOAL_ACTIVE, GOAL_INACTIVE, GOAL_COMPLETED, GOAL_FAILED}

func init(_human,_params):
	human = _human
	if _params:
		params = _params
	
func active():
	pass

func process(_delta: float):
	return STATE.GOAL_COMPLETED
	
func terminate():
	pass
