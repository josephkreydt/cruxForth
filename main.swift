import Foundation

print("Welcome to cruxForth\n>>>>", terminator:"")

var intStack: [Int] = []
var compileFlag: Bool = false
var compiledWords: String = ""

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
		
		if compileFlag == true {
			if input == "compiler" {
				print(compiledWords)
			} else if input == ";" {
				endCompile()
			} else {
				compile(input: input)
			}
		} else {
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
				} else if input == ":" {
					startCompile()
				} else if input == "compiler" {
					print(compiledWords)
				} else if input == ";" {
					print("not in compile mode")
				} else if compiledWords.contains(":::: " + input) {
					print("exists in dict")
				}
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

func startCompile() {
	compileFlag = true
	compiledWords.append("::::")
}

func compile(input: String) {
	compiledWords.append(" " + input)
}

func endCompile() {
	compiledWords.append(" ;;;; ")
	compileFlag = false
}
