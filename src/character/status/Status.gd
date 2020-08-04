extends Node


var statusDic:Dictionary = {}

#一分钟-更新状态值 可以修改快速看到状态值得改变
export var update_time = 60
#暂停时剩余的时间
var pause_left_time:float = 0

onready var updateTimer := $UpdaterTimer
func _ready():
	setup()
	start_update()
	
func pauseUpdate():
	pause_left_time = 0
	if updateTimer.is_stopped() == false:
		pause_left_time = updateTimer.time_left
		updateTimer.stop()
	
func start_update():
	if updateTimer.is_stopped():
		updateTimer.start(update_time - pause_left_time)
		pause_left_time = 0

#更新时间到了之后 更新数值 并重新计时
func _on_UpdaterTimer_timeout():
	update_status()
	start_update()
	print("=====================")

func update_status():
	for status in statusDic.values():
		status.update_status(statusDic)





func setup():
	load_status_config_and_parse()
	binding_status_listner_relative()

func binding_status_listner_relative():
	for status in statusDic.values():
		status.binding_status_listner_relative(statusDic)

func load_status_config_and_parse():
	var data_file = File.new()
	if data_file.open("res://config/status.json", File.READ) != OK:
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return
		
	if typeof(data_parse.result) == TYPE_ARRAY:
		parse_status(data_parse.result)
	else:
		print("unexpected results")

func parse_status(status_arr):
	for item in status_arr:
		var status_model := StatusModel.new()
		var status_name = item["状态名"]
		status_model.status_name = status_name
		
		if item.has("影响状态的条件组"):
			var effects = item["影响状态的条件组"]
			if typeof(effects) == TYPE_ARRAY:
				var status_conditions = parse_conditions(effects)
				status_model.status_conditions = status_conditions
			else:
				print("unexpected results")
				
		statusDic[status_name] = status_model

#解析条件队列
func parse_conditions(effects_arr):
	var status_effect_arr = []
	for item in effects_arr:
		var status_effect = StatusEffectModel.new()
		var condition_name = item["条件名"]
		status_effect.condition_name = condition_name
		
		var condition_arr = item["条件集合"]
		var conditon_arr_result = parse_condition_arr(condition_arr)
		status_effect.condition_arr = conditon_arr_result
		
		#解析监听状态
		for condition_result in conditon_arr_result:
			var condition_relative_status_name = condition_result[0]
			status_effect.listner_status_name_dic[condition_relative_status_name] = 1
			
		
		var effect_arr = item["影响集合"]
		var effect_arr_result = parse_effect_arr(effect_arr)
		status_effect.effect_arr = effect_arr_result
		
		status_effect_arr.push_back(status_effect)
	return status_effect_arr

#解析子条件集合		
func parse_condition_arr(condition_arr):
	var condition_arr_result = []
	for item in condition_arr:
		condition_arr_result.push_back(item.split(","))
	return condition_arr_result

#解析子影响集合
func parse_effect_arr(effect_arr):
	var effect_arr_result = []
	for item in effect_arr:
		effect_arr_result.push_back(item.split(","))
	return effect_arr_result
