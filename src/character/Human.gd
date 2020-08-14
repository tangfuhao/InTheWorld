extends KinematicBody2D
class_name Player

export var show_log := false
export var player_name = "player1"
onready var playerName = $LabelLayout/PlayerName
onready var movement = $Movement
onready var cpu = $"CPU"
onready var hurt_box = $HurtBox
onready var hit_box = $HitBox
#与目标的距离
var _target_distance = 0
signal to_target_distance_update(distance)
signal be_hurt(area)
#背包
var package = []
#目标
var target = null setget set_target,get_target

signal disappear_notify

func _process(delta):
	update_target_distance()

func update_target_distance():
	if target:
		var latest_distance_to_target = global_position.distance_to(target.global_position)
		var margin_of_error = _target_distance - latest_distance_to_target
		if margin_of_error > 5 || margin_of_error < -5:
			_target_distance = latest_distance_to_target
			emit_signal("to_target_distance_update",_target_distance)

func _ready() -> void:
	playerName.text = player_name

func handle_target_disappear_notify(_target):
	if target:
		target.disconnect("disappear_notify",self,"handle_target_disappear_notify")
	target = null

func set_target(_target):
	if target != _target:
		if target:
			target.disconnect("disappear_notify",self,"handle_target_disappear_notify")
		if _target:
			_target.connect("disappear_notify",self,"handle_target_disappear_notify")
		target = _target
		update_target_distance()
		if target is Stuff:
			print(player_name,"的目标改为:",target.stuff_name)
		else:
			print(player_name,"的目标改为:",target.player_name)
			

func get_target():
	return target

func is_approach(_target):
	var tolerance = 100
	return global_position.distance_squared_to(_target.global_position) < tolerance
		
func pick_up(_target:Stuff) -> void:
	var item = PackageItemModel.new()
	item.item_name = _target.stuff_name
	package.push_back(item)
	_target.notify_disappear()
	_target.queue_free()
	print(player_name,"捡起了",_target.stuff_name)

#受到伤害
func _on_HurtBox_area_entered(area):
	var health_status = cpu.status.statusDic["健康状态"]
	hurt_box.start_invincibility(0.5)
	hurt_box.show_attack_effect()
	emit_signal("be_hurt",area)

func has_attribute(_params):
	return _params == "其他人"
	
func notify_disappear():
	emit_signal("disappear_notify",self)
