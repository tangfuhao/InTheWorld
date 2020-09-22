extends AroundPeopleSensor
class_name AroundLikePeopleSensor
#周围喜欢的人

var like_people_arr := []
var like_people_in_bed_arr := []
var like_people_no_wear_arr := []


func setup(_control_node):
	.setup(_control_node)
	_control_node.connect("location_change",self,"_on_self_location_change")


func _on_player_action_notify(_body,_action_name,_is_active):
	if _action_name == "脱":
		if _is_active:
			like_people_no_wear_arr.push_back(_body)
			world_status.set_world_status("看到喜欢的人没穿衣服",true)
		else:
			assert(false)
	elif _action_name == "穿":
		if _is_active:
			like_people_no_wear_arr.erase(_body)
			world_status.set_world_status("看到喜欢的人没穿衣服",!like_people_no_wear_arr.empty())
		else:
			assert(false)
			
func _on_self_location_change(_body,_location_name):
	update_like_people_in_bed()

func _on_player_location_change(_body,_location_name):
	if _body.location == "床":
		if not like_people_in_bed_arr.has(_body):
			like_people_in_bed_arr.push_back(_body)
	elif like_people_in_bed_arr.has(_body):
		like_people_in_bed_arr.erase(_body)
		
	update_like_people_in_bed()


func update_like_people_in_bed():
	if control_node.location == "床" and not like_people_in_bed_arr.empty():
		world_status.set_world_status("和喜欢的人在床上",true)
	else:
		world_status.set_world_status("和喜欢的人在床上",false)

func on_vision_find_player(_body):
	var is_like = control_node.is_like_people(_body)
	if is_like:
		like_people_arr.push_back(_body)
		_body.connect("player_action_notify",self,"_on_player_action_notify")
		_body.connect("location_change",self,"_on_player_location_change")
		
		world_status.set_world_status("看到喜欢的人",true)

		if not _body.is_wear_clothes:
			like_people_no_wear_arr.push_back(_body)
			world_status.set_world_status("看到喜欢的人没穿衣服",true)
			
		if like_people_arr.size() == control_node.visionSensor.monitoring_arr_type_dic.size():
			world_status.set_world_status("周围只有喜欢的人",true)
		
		_on_player_location_change(_body,_body.location)
	else:
		world_status.set_world_status("周围只有喜欢的人",false)

func on_vision_lost_player(_body):
	var is_like_people_in_bed = like_people_in_bed_arr.has(_body)
	var is_like = like_people_arr.has(_body)
	var is_like_no_wear = like_people_no_wear_arr.has(_body)
	
	if is_like:
		like_people_arr.erase(_body)
		_body.disconnect("player_action_notify",self,"_on_player_action_notify")
		_body.disconnect("location_change",self,"_on_player_location_change")
		world_status.set_world_status("看到喜欢的人",!like_people_arr.empty())
		
	world_status.set_world_status("周围只有喜欢的人",like_people_arr.size() == control_node.visionSensor.monitoring_arr_type_dic.size())
	
	if is_like_people_in_bed:
		like_people_in_bed_arr.erase(_body)
		update_like_people_in_bed()

	if is_like_no_wear:
		like_people_no_wear_arr.erase(_body)
		world_status.set_world_status("看到喜欢的人没穿衣服",!like_people_no_wear_arr.empty())
	
