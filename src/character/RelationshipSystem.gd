#关系系统
class_name RelationshipSystem
#喜爱值表 名-值
var player_lover_dic = {}


func get_relation_value_for_player(_relation_name,_player) -> float:
	if not player_lover_dic.has(_player.player_name):
		return 0.0
	return float(player_lover_dic[_player.player_name])

func set_relation_value_for_player(_relation_name,_player,_value):
	player_lover_dic[_player.player_name] = _value
	
#交互行为
func interaction_action(_player,_action_name):
	var lover_value = get_relation_value_for_player("喜爱值",_player)
	lover_value = lover_value + effect_value_by_interaction_action(_action_name,lover_value)

#监听默认行为
func bind_player_vision(_player):
	_player.connect("find_some_one",self,"_on_vision_some_one")
	_player.connect("un_find_some_one",self,"_on_vision_un_some_one")

func _on_vision_some_one(_body):
	_body.connect("player_action_notify",self,"_on_around_player_action_notify")
	
func _on_vision_un_some_one(_body):
	_body.disconnect("player_action_notify",self,"_on_around_player_action_notify")

func _on_around_player_action_notify(_player,_action_name,_is_active):
	if _is_active:
		var lover_value = get_relation_value_for_player("喜爱值",_player)
		lover_value = lover_value + effect_value_by_action(_action_name,lover_value)

func effect_value_by_action(_action_name,_lover_vale):
	match _action_name:
		"检查电力系统":
			return 0.1
		"排泄":
			return -0.2


func effect_value_by_interaction_action(_action_name,_lover_vale):
	match _action_name:
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

























