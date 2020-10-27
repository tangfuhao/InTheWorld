#对属性的状态
class_name ParamStatus
var name 
var duration 
var record_time := 0.0

var is_vaild = true

#参数在buff下的定义
var buff_param_dic := {}
##保存在状态下的 参数定义 json格式  缓存在当前
#var config_param_dic := {}


signal status_time_out

func _init(_buff_config):
	#名称
	name = _buff_config["buff_name"]
#	config_param_dic = _buff_config["param_config"]
	#限时
	if _buff_config.has("duration"):
		duration = _buff_config["duration"]

	#buff 值范围限定
	var param_config_arr = _buff_config["buff_param_config"]
	for item in param_config_arr:
		var param_name = item["name"]
		var param_model = ComomStuffParam.new()
		param_model.name = param_name
		
		if item.has("max_value"):
			param_model.max_value = item["max_value"]
		
		if item.has("min_value"):
			param_model.min_value = item["min_value"]
		
		#不存在
#		if item.has("transform"):
#			param_model.transform = item["transform"]
		
		if item.has("init_value"):
			param_model.init_value = item["init_value"]
			param_model.value = param_model.init_value

		buff_param_dic[param_name] = param_model
		
	#对值的transform
	#TODO

func _process(_detal):
	#如果无效 就返回
	if not is_vaild:
		return 

	#更新状态改变的属性
	for item in buff_param_dic.values():
		item._process(_detal)

	#如果存在限时
	if duration:
		record_time = record_time + _detal
		#如果限时超过 设置时间 就返回
		if record_time > duration:
			emit_signal("status_time_out")
			is_vaild = false



#获取修改过的参数值
func get_status_param_value() -> Dictionary:
	var status_param_value = {}
	for item in buff_param_dic.values():
		status_param_value[item.name] = item.value
	return status_param_value
