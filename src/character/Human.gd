extends KinematicBody2D
class_name Player

export var player_name = "player1"
onready var playerName = $LabelLayout/PlayerName
onready var movement = $Movement
onready var cpu = $"CPU"
onready var hurt_box = $HurtBox
onready var hit_box = $HitBox
#与目标的距离
var _target_distance = 0
signal to_target_distance_update(distance)
#背包
var package = []
#目标
var target = null setget set_target,get_target


var is_hide = false

func _process(delta):
	update_target_distance()

func update_target_distance():
	if target:
		var latest_distance_to_target = global_position.distance_to(target.global_position)
		var margin_of_error = _target_distance - latest_distance_to_target
		if margin_of_error > 5:
			_target_distance = latest_distance_to_target
			emit_signal("to_target_distance_update",_target_distance)

func _ready() -> void:
	playerName.text = player_name

func set_target(_target):
	target = _target
	update_target_distance()
func get_target():
	return target

func is_approach(_target):
	var tolerance = 100
	return global_position.distance_squared_to(_target.global_position) < tolerance
		
func pick_up(_target:Stuff) -> void:
	var item = PackageItemModel.new()
	item.item_name = _target.stuff_name
	package.push_back(item)
	_target.queue_free()

#受到伤害
func _on_HurtBox_area_entered(area):
	var health_status = cpu.status.statusDic["健康状态"]
	hurt_box.start_invincibility(0.5)
	hurt_box.show_attack_effect()
