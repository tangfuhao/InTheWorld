extends "res://src/Character/tasks/Task.gd"
class_name Eat

var action_time
var player_ui

func active():
	.active()
	self.action_target = get_params()
	action_time = float(action_target.get_function("可被食用","动作时间"))
	
	if action_target is CommonStuff and not action_target.can_interaction(human):
		goal_status = STATE.GOAL_FAILED
		
	player_ui = human.get_node("/root/Island/UI/PlayerUI")
	player_ui.show_action_bar(human,action_time)


func process(_delta: float):
	.process(_delta)
	
	action_time = action_time - _delta
	if action_time < 0:
		goal_status = STATE.GOAL_COMPLETED
	
	return goal_status


func terminate() ->void:
	.terminate()
	player_ui.dismiss_action_bar(human)
	
	if goal_status == STATE.GOAL_COMPLETED:
		var effect_str = action_target.get_function("可被食用","动作影响")
		assert(effect_str != null)
						
		if effect_str:
			#动作影响
			var effect_item_arr = effect_str.split(":")
			for item in effect_item_arr:
				var effect_param_arr = Array(item.split(",") )
				var runner = effect_param_arr.pop_front()
				if runner == "物品":
					action_target.excute_effect(effect_param_arr)
				elif runner == "自己":
					human.excute_effect(effect_param_arr)
		
		human.inventory_system.remove_item_in_package(action_target)
