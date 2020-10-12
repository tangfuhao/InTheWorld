extends Panel

onready var animation_player := $AnimationPlayer



func play(_position,_action_time):
	show()
	set_global_position(_position)
	var speed = 1.0 / _action_time
	animation_player.play("play",-1,speed)
	
func stop():
	if animation_player.is_playing():
		animation_player.stop()
	hide()


func _on_AnimationPlayer_animation_finished(anim_name):
	hide()
