extends AroundPeopleSensor
class_name AroundLikePeopleSensor
#周围喜欢的人

var like_people_arr := []
var like_people_in_bed_arr := []
var like_people_no_wear_arr := []

func on_vision_find_player(_body):
	var is_like = control_node.is_like_people(_body)
	if is_like:
		like_people_arr.push_back(_body)
		world_status.set_world_status("看到喜欢的人",true)

		if not _body.is_wear_clothes:
			like_people_no_wear_arr.push_back(_body)
			world_status.set_world_status("看到喜欢的人没穿衣服",true)
			
		if like_people_arr.size() == control_node.visionSensor.monitoring_arr_type_dic.size():
			world_status.set_world_status("周围只有喜欢的人",true)
		
		if _body.location == "床":
			like_people_in_bed_arr.push_back(_body)
			if control_node.location == "床":
				world_status.set_world_status("和喜欢的人在床上",true)
	else:
		world_status.set_world_status("周围只有喜欢的人",false)

func on_vision_lost_player(_body):
	var is_like_people_in_bed = like_people_in_bed_arr.has(_body)
	var is_like = like_people_arr.has(_body)
	var is_like_no_wear = like_people_no_wear_arr.has(_body)
	
	if is_like:
		like_people_arr.erase(_body)
		world_status.set_world_status("看到喜欢的人",!like_people_arr.empty())
	
	if is_like_people_in_bed:
		like_people_in_bed_arr.erase(_body)
		world_status.set_world_status("和喜欢的人在床上",!like_people_arr.empty())

	world_status.set_world_status("周围只有喜欢的人",like_people_arr.size() == control_node.visionSensor.monitoring_arr_type_dic.size())
		
	if is_like_no_wear:
		var is_togeter_in_bed = !is_like_no_wear.empty() and control_node.location == "床"
		world_status.set_world_status("和喜欢的人在床上",is_togeter_in_bed)
	
