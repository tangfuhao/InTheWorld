class_name RelationshipSystem
#关系系统
var owner

#喜爱值表 名-值
var player_lover_dic = {}


func get_relation_value_for_player(_relation_name,_player) -> float:
	if not player_lover_dic.has(_player.player_name):
		return 0.7
	return float(player_lover_dic[_player.player_name])

func set_relation_value_for_player(_relation_name,_player,_value):
	if _value < 0:
		_value = 0
	if _value > 0.9:
		_value = 0.9
	player_lover_dic[_player.player_name] = _value
	if _relation_name == "喜爱值":
		GlobalMessageGenerator.send_player_lover_value_change(owner,_player,_value)
	
#交互行为
func interaction_action(_player,_action_name):
	var lover_value = get_relation_value_for_player("喜爱值",_player)
	var effect_value = effect_value_by_interaction_action(_action_name,lover_value)
	if effect_value:
		lover_value = lover_value + effect_value
		set_relation_value_for_player("喜爱值",_player,lover_value)
		# print("由于",_player.player_name,"对",owner_name,"执行:",_action_name,"，",owner_name,"对其喜爱值受影响：",effect_value,".最终为：",lover_value)

#监听默认行为
func bind_player_vision(_player):
	owner = _player
	_player.visionSensor.connect("vision_find_player",self,"_on_vision_some_one")
	_player.visionSensor.connect("vision_lost_player",self,"_on_vision_un_some_one")

func _on_vision_some_one(_body):
	_body.connect("player_action_notify",self,"_on_around_player_action_notify")
	
func _on_vision_un_some_one(_body):
	_body.disconnect("player_action_notify",self,"_on_around_player_action_notify")

func _on_around_player_action_notify(_player,_action_name,_is_active):
	if _is_active:
		var lover_value = get_relation_value_for_player("喜爱值",_player)
#		lover_value = lover_value + effect_value_by_action(_action_name,lover_value)
#		set_relation_value_for_player("喜爱值",_player,lover_value)
		var effect_value = effect_value_by_action(_action_name,lover_value)
		if effect_value:
			lover_value = lover_value + effect_value
			set_relation_value_for_player("喜爱值",_player,lover_value)
			GlobalMessageGenerator.send_player_lover_effect(owner,_player,effect_value,_action_name)
				
			# print("由于看到",_player.player_name,"执行:",_action_name,"，",owner_name,"对其喜爱值受影响：",effect_value,".最终为：",lover_value)
			
func effect_value_by_action(_action_name,_lover_vale):
	match _action_name:
		"检查电力系统":
			return 0.1
		"排泄":
			return -0.2
	return 0


func effect_value_by_interaction_action(_action_name,_lover_vale):
	match _action_name:
		"聊天":
			return 0.05
		"弹情歌":
			return 0.3
		"喝酒":
			#TODO 对方和我两个人喝酒 少判断
			return 0.1
		"回复求助":
			return 0.3
		"表白":
			if _lover_vale > 0.5:
				return 0.2
			return 0
		"手机表白":
			if _lover_vale > 0.5:
				return 0.1
			return 0 
		"亲吻":
			if _lover_vale < 0.7:
				return -0.4
			return 0
		"亲脸":
			if _lover_vale < 0.7:
				return -0.3
			return 0
		"牵手":
			if _lover_vale < 0.7:
				return -0.3
			return 0
		"伸手摸":
			if _lover_vale < 0.7:
				return -0.5
			return 0
		"做爱":
			if _lover_vale < 0.8:
				return -1
			return 0
		"一起上床":
			if _lover_vale < 0.8:
				return -1
			return 0
	return 0
