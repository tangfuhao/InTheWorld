class_name Calculator
#引擎 计算
var LEFT_BRACKET = '('
var RIGHT_BRACKET = ')'
var BLANK = ' '
var DECIMAL_POINT = '.'
var NEGATIVE_SIGN = '-'
var POSITIVE_SIGN = '+'
var SEPARATOR = ' '

var operator = Operator.new()

func eval(expression):
	var result = infix2Suffix(expression)
	return evalInfix(result)

func infix2Suffix(expression):
	if not expression:
		return null
	
	var sb :PoolStringArray
	var stack = []
	var chs = expression
	var appendSeparator = false
	var is_sign = true
	for c in chs:
		if c == BLANK:
			continue
		if appendSeparator:
			sb.append(SEPARATOR)
			appendSeparator = false
			
			
		if isSign(c) and is_sign:
			sb.append(c)
		elif isNumber(c):
			is_sign = false
			sb.append(c)
		elif isLeftBracket(c):
			stack.push_back(c)
		elif isRightBracket(c):
			is_sign = false
			while(stack.back() != LEFT_BRACKET):
				sb.append(SEPARATOR)
				sb.append(stack.pop_back())
			stack.pop_back()
		else:
			appendSeparator = true
			if operator.isOperator(c):
				is_sign = true
				
				if stack.empty() or stack.back() == LEFT_BRACKET:
					stack.push_back(c)
					continue
				var precedence = operator.getPrority(c)
				while not stack.empty() and operator.getPrority(stack.back()) >= precedence:
					sb.append(SEPARATOR)
					sb.append(stack.pop_back())
				stack.push_back(c)
	
	while not stack.empty():
		sb.append(SEPARATOR)
		sb.append(stack.pop_back())
	
	var ssss =  sb.join("")
	return ssss
	
func isSign(c):
	return c == NEGATIVE_SIGN or c == POSITIVE_SIGN

func isNumber(c):
	return (c >= '0' and c <= '9') or c == DECIMAL_POINT

func isLeftBracket(c):
	return c == LEFT_BRACKET
func isRightBracket(c):
	return c == RIGHT_BRACKET


func evalInfix(expression):
#	var regex = RegEx.new()
#	regex.compile("\\s+")
#	var match_arr = regex.search_all(expression)
#	var strs = []
#	for item in match_arr:
#		strs.push_back(item.get_string())
	var strs = Array(expression.split(" "))
		
	var stack = []
	for item in strs:
		if not operator.isOperator(item):
			stack.push_back(float(item))
		else:
			var op = operator.getInstance(item)
			var right = stack.pop_back()
			var left = stack.pop_back()
			var result = op.eval(left,right)
			stack.push_back(result)
	return stack.pop_back()
