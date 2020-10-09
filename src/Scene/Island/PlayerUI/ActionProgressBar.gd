extends Panel

onready var animation_player = $AnimationPlayer



func play(_position):
	set_global_position(Vector2(_position.x - 50,_position.y - 50))
	self.visible = true
	animation_player.play("play")


func _on_AnimationPlayer_animation_finished(anim_name):
	self.visible = false
