import Foundation

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    } // add ability to get index of a string rather than just a single character
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
} // extension brought to you by: https://stackoverflow.com/questions/32305891/index-of-a-substring-in-a-string-with-swift

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
					runWord(word: input)
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

func runWord(word: String) {
	let formattedWord: String = ":::: " + word + " "
	var fullDefinition: String.SubSequence = ""
	var definition: String.SubSequence = ""
	
	if let wordIndex = compiledWords.endIndex(of: formattedWord) {
		fullDefinition = compiledWords[wordIndex...]
	}
	if let wordIndex = fullDefinition.index(of: ";") {
		definition = fullDefinition[..<wordIndex]
	}
	print(definition)
}
