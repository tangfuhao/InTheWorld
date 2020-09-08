class_name SelfHurtSensor
extends Sensor
#伤害传感器

var hurt_timer

func setup(_control_node):
	.setup(_control_node)
	
	
	control_node.hurt_box.connect("area_entered",self,"_on_HurtBox_area_entered")
	
	hurt_timer = Timer.new()
	hurt_timer.connect("timeout",self,"_on_HurtTimer_timeout")
	control_node.add_child(hurt_timer)


func on_character_be_hurt(area):
	world_status.set_world_status("受到攻击",true)
	world_status.set_world_status("不受攻击十秒",false)
	
	if hurt_timer.is_stopped():
		hurt_timer.start(10)
	else:
		hurt_timer.stop()
		hurt_timer.start(10)

func _on_HurtTimer_timeout():
	world_status.set_world_status("受到攻击",false)
	world_status.set_world_status("不受攻击十秒",true)


#受到伤害
func _on_HurtBox_area_entered(area):
	if area.player == control_node:
		return 
	control_node.hurt_box.start_invincibility(0.5)
	control_node.hurt_box.show_attack_effect()
	
	if area.damage:
		control_node.be_hurt(area.damage)
	on_character_be_hurt(area)
	

