extends "res://src/Character/tasks/NoLimitTask.gd"
class_name Collect
#采集

var player_ui
var action_time



func active():
	.active()
	
	self.action_target = get_params()
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
	player_ui.dismiss_action_bar(human)
	
	if goal_status == STATE.GOAL_COMPLETED:
		var effect_str = action_target.get_function("可被采集","动作影响")
		var collect_stuffs_str = action_target.get_function("可被采集","采集物品")
		assert(effect_str != null)
		assert(collect_stuffs_str != null)
		
		if collect_stuffs_str:
			#采集结果
			var collect_stuff_str_arr = Array(collect_stuffs_str.split(","))

			var main_scence
			for item in collect_stuff_str_arr:
				var collect_stuff_params = item.split(":")
				var chance = float(collect_stuff_params[0])
				var stuff_type_name = collect_stuff_params[1]
				
				if randf() < chance:
					var stuff = DataManager.instance_stuff_script(stuff_type_name)
					if not human.inventory_system.add_stuff_to_package(stuff):
						#扔地下
						if not main_scence:
							main_scence = human.get_node("/root/Island")
						
						var stuff_node = DataManager.instance_stuff_scene()
						stuff_node.copy_config_data(stuff)
						main_scence.customer_node_group.add_child(stuff_node)
						main_scence.binding_customer_node_item(stuff_node)
						stuff_node.set_global_position(human.get_global_position())
						
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




