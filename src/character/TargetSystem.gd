class_name TargetSystem
#目标系统

signal target_change(target)

#目标
var target = null setget set_target

func _on_target_disappear_notify(_target):
	if target:
		target.disconnect("disappear_notify",self,"_on_target_disappear_notify")
	target = null

func set_target(_target):
	if target != _target:
		if target:
			target.disconnect("disappear_notify",self,"_on_target_disappear_notify")
		if _target:
			_target.connect("disappear_notify",self,"_on_target_disappear_notify")
		target = _target
		emit_signal("target_change",target)
