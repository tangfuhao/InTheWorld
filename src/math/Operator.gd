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
