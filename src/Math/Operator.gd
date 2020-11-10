class_name Operator
#运算符
var operators = {}

class OperatorXXX:
	var operator:String
	var priority:int




class ADITION:
	var operator:String
	var priority:int
	func _init(_operator,_priority):
		operator = _operator
		priority = _priority
	func eval(left,right):
		return left + right

class SUBTRATION:
	var operator:String
	var priority:int
	func _init(_operator,_priority):
		operator = _operator
		priority = _priority
	func eval(left,right):
		return left - right

class MULTIPLICATION:
	var operator:String
	var priority:int
	func _init(_operator,_priority):
		operator = _operator
		priority = _priority
	func eval(left,right):
		return left * right
		
class DIVITION:
	var operator:String
	var priority:int
	func _init(_operator,_priority):
		operator = _operator
		priority = _priority
	func eval(left,right):
		return left / right
		
class EXPONENT:
	var operator:String
	var priority:int
	func _init(_operator,_priority):
		operator = _operator
		priority = _priority
	func eval(left,right):
		return int(left) ^ int(right)
		
class GREATER_THEN:
	var operator:String
	var priority:int
	func _init(_operator,_priority):
		operator = _operator
		priority = _priority
	func eval(left,right):
		if left > right:
			return 1
		else:
			return 0

class LESS_THEN:
	var operator:String
	var priority:int
	func _init(_operator,_priority):
		operator = _operator
		priority = _priority
	func eval(left,right):
		if left < right:
			return 1
		else:
			return 0
			
class GREATER_THEN_OR_EQUAL_TO:
	var operator:String
	var priority:int
	func _init(_operator,_priority):
		operator = _operator
		priority = _priority
	func eval(left,right):
		if left >= right:
			return 1
		else:
			return 0

class LESS_THEN_OR_EQUAL_TO:
	var operator:String
	var priority:int
	func _init(_operator,_priority):
		operator = _operator
		priority = _priority
	func eval(left,right):
		if left <= right:
			return 1
		else:
			return 0
			
class EQUAL_TO:
	var operator:String
	var priority:int
	func _init(_operator,_priority):
		operator = _operator
		priority = _priority
	func eval(left,right):
		if left == right:
			return 1
		else:
			return 0

class NOT_EQUAL_TO:
	var operator:String
	var priority:int
	func _init(_operator,_priority):
		operator = _operator
		priority = _priority
	func eval(left,right):
		if left != right:
			return 1
		else:
			return 0
			
class OR:
	var operator:String
	var priority:int
	func _init(_operator,_priority):
		operator = _operator
		priority = _priority
	func eval(left,right):
		if left or right:
			return 1
		else:
			return 0
			
class AND:
	var operator:String
	var priority:int
	func _init(_operator,_priority):
		operator = _operator
		priority = _priority
	func eval(left,right):
		if left and right:
			return 1
		else:
			return 0
	
func _init():
	var op = ADITION.new('+', 100)
	register(op)
	op = SUBTRATION.new('-', 100)
	register(op)
	op = MULTIPLICATION.new('*', 200)
	register(op)
	op = DIVITION.new('/', 200)
	register(op)
	op = EXPONENT.new('^', 300)
	register(op)
	
	op = OR.new('∨', 95)
	register(op)
	op = AND.new('∧', 95)
	register(op)
	
	op = GREATER_THEN.new('>', 90)
	register(op)
	op = GREATER_THEN_OR_EQUAL_TO.new('≥', 90)
	register(op)
	
	op = LESS_THEN.new('<', 90)
	register(op)
	op = LESS_THEN_OR_EQUAL_TO.new('≤', 90)
	register(op)
	
	op = EQUAL_TO.new('≡', 90)
	register(op)
	op = NOT_EQUAL_TO.new('≠', 90)
	register(op)
	


func register(_operator):
	operators[_operator.operator] = _operator
	
func isOperator(c):
	return operators.has(c)

func getInstance(c):
	return operators[c]

func getPrority(c):
	var op = getInstance(c)
	if op:
		return op.priority
	return 0
