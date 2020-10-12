extends "res://src/Character/tasks/NoLimitTask.gd"
class_name Collect
#采集

var player_ui
var action_time

func active():
	.active()
	
	action_target = get_params()
	assert(action_target and action_target is CommonStuff)
	
	if not action_target.can_interaction(human):
		goal_status = STATE.GOAL_FAILED
		return 
	
	assert(action_target.get_function("可被采集","动作时间"))
	action_time = float(action_target.get_function("可被采集","动作时间"))

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
	player_ui.dismiss_action_bar()
	
	if goal_status == STATE.GOAL_COMPLETED:
		var effect_str = action_target.get_function("可被采集","动作影响")
		var collect_stuffs_str = action_target.get_function("可被采集","采集物品")
		assert(effect_str != null)
		assert(collect_stuffs_str != null)
		
		if collect_stuffs_str:
			#采集结果
			var collect_stuff_str_arr = Array(collect_stuffs_str.split(","))
			for item in collect_stuff_str_arr:
				var collect_stuff_params = item.split(":")
				var chance = float(collect_stuff_params[0])
				var stuff_name = collect_stuff_params[1]
				
				if randf() < chance:
					var stuff = instance_stuff(stuff_name)
					human.inventory_system.add_stuff_to_package(stuff)
		if effect_str:
			#采集影响
			action_target.excute_effect(effect_str)



func instance_stuff(_stuff_name):
	print("instance_stuff")
	pass
