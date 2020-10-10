class_name Evaluate

func evaluateBoolean(property, condition, value) -> bool:
	print(get(property), ' ', condition, ' ', value)
	if condition == '==':
		return get(property) == value
	elif condition == '!=':
		return get(property) != value
	elif condition == '>':
		return get(property) > value
	elif condition == '>=':
		return get(property) >= value
	elif condition == '<':
		return get(property) < value
	elif condition == '<=':
		return get(property) <= value
	else:
		return false
		
# func evaluateResult(property, condition, value) -> void:
# #	print(get(property), ' ', condition, ' ', value)
# 	if condition == '-':
# 		var result = property - value
# 		property = result
	
# 	elif condition == '+':
# 		var result = property + value
# 		property = result

