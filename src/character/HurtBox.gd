extends Area2D


var invincible = false setget set_invincible
signal invincibility_start
signal invinciblility_end

onready var timer = $Timer


func show_attack_effect():
	var GrassEffect = load("res://src/character/AttachEffect.tscn")
	var grassEffect = GrassEffect.instance()
	get_tree().current_scene.add_child(grassEffect)
	grassEffect.global_position = global_position


func set_invincible(value):
	invincible = value
	if invincible :
		emit_signal("invincibility_start")
	else:
		emit_signal("invinciblility_end")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)
	

func _on_Timer_timeout():
	self.invincible = false


func _on_HurtBox_invincibility_start():
	set_deferred("monitoring",false)


func _on_HurtBox_invinciblility_end():
	monitoring = true
