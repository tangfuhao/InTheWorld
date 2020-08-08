extends Node2D


func meet_condition(_condition_item) -> bool :
	if _condition_item == "周围有其他人":
		return true
	elif _condition_item == "受到攻击":
		return true
	return false
