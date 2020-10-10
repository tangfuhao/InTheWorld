extends "res://src/Character/tasks/NoLimitTask.gd"
class_name Collect
#采集

var action_time
var effect_str
var collect_stuffs_str
func active():
	.active()
	
	action_target = get_params()

	if not human.is_approach(action_target.get_global_position(),10):
		goal_status = STATE.GOAL_FAILED
	else:
		var function_attribute = action_target.get_function("可被采集")
		if function_attribute:
			action_time = float(function_attribute["动作时间"])
			effect_str = function_attribute["动作影响"]
			collect_stuffs_str = function_attribute["采集物品"]
			var player_ui = human.get_node("/root/Island/UI/PlayerUI")
			player_ui.show_action_bar(human,action_time)
		else:
			goal_status = STATE.GOAL_FAILED


func process(_delta: float):
	.process(_delta)
	
	action_time = action_time - _delta
	if action_time < 0:
		goal_status = STATE.GOAL_COMPLETED
	
	return goal_status
	
func terminate() ->void:
	.terminate()
	if goal_status == STATE.GOAL_COMPLETED:
		#采集结果
		var collect_stuff_str_arr = Array(collect_stuffs_str.split(","))
		var random_chance = randf()
		for item in collect_stuff_str_arr:
			var collect_stuff_params = item.split(":")
			var chance = collect_stuff_params[0]
			var stuff_name = collect_stuff_params[1]
			
			if random_chance < chance:
				var stuff = instance_stuff(stuff_name)
				human.inventory_system.add_stuff_to_package(stuff)
		#采集影响
		action_target.excute_effect(effect_str)
	else:
		pass


func instance_stuff(_stuff_name):
	pass
