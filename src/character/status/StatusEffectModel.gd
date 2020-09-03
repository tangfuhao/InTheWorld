class_name StatusEffectModel
var condition_name:String
var condition_arr:Array
var effect_arr:Array 
var listner_status_name_dic:Dictionary = {}

#条件是否满足
var is_active:bool = false

#绑定监听的状态
func binding_status_listner_relative(statusDic):
	for listner_status_name in listner_status_name_dic.keys():
		var listner_status = statusDic[listner_status_name]
		listner_status_name_dic[listner_status_name] = listner_status.status_value
		listner_status.connect("status_value_update",self,"_on_status_value_update")
	
	check_condition_meet()


#监听的状态值发生改变
func _on_status_value_update(status):
	var status_value = status.status_value
	listner_status_name_dic[status.status_name] = status_value
	check_condition_meet()

func check_condition_meet():
	var is_active_temp = is_active
	if condition_arr.empty() == false:
		var is_meet = true
		var index = 0
		var size = condition_arr.size()
		while is_meet && index != size:
			var condition = condition_arr[index]
			var condition_relative_status_name = condition[0]
			var condition_str = condition[1]
			var value_str = condition[2]
			var property = listner_status_name_dic[condition_relative_status_name]
			is_meet = is_meet && evaluateBoolean(property,condition_str,float(value_str))
			index = index + 1
		is_active = is_meet
	else:
		#如果没有条件 那么直接满足
		is_active = true
		

	if is_active == is_active_temp: return
	# if is_active:
	# 	print(condition_name,"---被激活")
	# else:
	# 	print(condition_name,"---停止激活")

func update_effects(statusDic):
	if is_active == false: return
	for effect in effect_arr:
		var property_str = effect[0]
		var condition_str = effect[1]
		var value_str = effect[2]

		var need_to_update_status = statusDic[property_str]
		need_to_update_status.status_value = evaluateResult(need_to_update_status.status_value,condition_str,float(value_str))

func evaluateBoolean(property, condition, value) -> bool:
#	print(property, ' ', condition, ' ', value)
	if condition == '==':
		return property == value
	elif condition == '!=':
		return property != value
	elif condition == '>':
		return property > value
	elif condition == '>=':
		return property >= value
	elif condition == '<':
		return property < value
	elif condition == '<=':
		return property <= value
	else:
		return false
		
func evaluateResult(property, condition, value) -> float:
#	print("evaluateResult=",property, ' ', condition, ' ', value)
	if condition == '-':
		var result = property - value
		return result
	elif condition == '+':
		var result = property + value
		return result
	return property
