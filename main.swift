import Foundation

print("Welcome to cruxForth\n>>>>", terminator:"")

var intStack: [Int] = []

while let input = readLine() {
	let input_array = input.components(separatedBy: " ")
	
	if processInput(input_array: input_array) {
		print("ok.")
	} else {
		break
	}
	print(">>>>", terminator:"")
}

func processInput(input_array: [String]) -> Bool {
	for input in input_array {
		if Int(input) != nil {
			intStack.append(Int(input) ?? 0)
		} else {
			//check dictionary
			if input == "show" {
				print(intStack)
			} else if input == "bye" {
				return false
			} else if input == "+" {
				add()
			} else if input == "-" {
				subtract()
			} else if input == "*" {
				multiply()
			} else if input == "/" {
				divide()
			} else if input == "pop" {
				pop()
			}
		}
	}
	return true
}

func add() {
	let topWord: Int = intStack.removeLast()
	let secondWord: Int = intStack.removeLast()
	let sum: Int = topWord + secondWord
	intStack.append(sum)
	print(sum)
}

func subtract() {
	let topWord: Int = intStack.removeLast()
	let secondWord: Int = intStack.removeLast()
	let difference: Int = secondWord - topWord
	intStack.append(difference)
	print(difference)
}

func multiply() {
	let topWord: Int = intStack.removeLast()
	let secondWord: Int = intStack.removeLast()
	let product: Int = secondWord * topWord
	intStack.append(product)
	print(product)
}

func divide() {
	let topWord: Int = intStack.removeLast()
	let secondWord: Int = intStack.removeLast()
	let dividend: Int = secondWord / topWord
	intStack.append(dividend)
	print(dividend)
}

func pop() {
	let topWord: Int = intStack.removeLast()
	print(topWord)
}
