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
var commentFlag: Bool = false
var compiledWords: String = ""
var indicesToIgnore: [Int] = []

while let input = readLine() {
	var input_array = input.components(separatedBy: " ")

	let returnCode = processInput(input_array: input_array, compiled: false)
	
	if returnCode == 1 && compileFlag == false {
		print("ok.")
	} else if returnCode == 1 && compileFlag == true {
		print("compiled.")
	} else if returnCode == 0 {
		break
	} else if returnCode == 2 {
		print("Due to error, input was not processed.")
		input_array = []
	}
	
	print(">>>>", terminator:"")
}

func processInput(input_array: [String], compiled: Bool) -> Int {
	indicesToIgnore = []
	var ifInputArray = input_array
	
	for (index, input) in input_array.enumerated() {
		let ignoreIndex = indicesToIgnore.contains(index)
		
		if ignoreIndex {
			print("ignore word: " + input + " because index is: ", index)
		} else {
			if compileFlag == true && commentFlag == false {
				if input == "compiler" {
					print(compiledWords)
				} else if input == ";" {
					endCompile()
				} else if input == ":" {
					print("Already in compile mode. Ingoring (:) operator.")
				} else if input == "(" {
					startComment()
				}
				else {
					if index > 0 && input_array[index - 1] == ":" {
						if Int(input) != nil {
							print("Error: word name cannot be an integer.")
							compileFlag = false
							compiledWords.removeLast(4)
							return 2
						} else {
							clearCompiledWord(word: input)
							compile(input: input)
						}
					} else {
						compile(input: input)
					}
				}
			} else if compileFlag == true && commentFlag == true {
				if input == ")" {
					endComment()
				}
			} else {
				if Int(input) != nil {
					intStack.append(Int(input) ?? 0)
				} else {
					//check dictionary
					if input == "show" {
						print(intStack)
					} else if input == "bye" {
						return 0
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
					} else if input == "=" {
						equal()
					} else if input == "<>" {
						notEqual()
					} else if input == "and" {
						and()
					} else if input == "or" {
						or()
					} else if input == ">" {
						greaterThan()
					} else if input == "<" {
						lessThan()
					} else if input == "dup" {
						dup()
					} else if input == "swap" {
						swap()
					} else if input == "2dup" {
						twoDup()
					} else if input == "rot" {
						rot()
					} else if input == "if" {
						let stackEvalReturn = evaluateStack()
						ifInputArray = processIfElse(stackEval: stackEvalReturn, index: index, input_array: ifInputArray, compiled: compiled)
					}
					else if input == ":" {
						startCompile()
					} else if input == "immediate" {
						let wordToRun = lastCompiledWord()
						let runWordReturnCode = runWord(word: wordToRun)
						if runWordReturnCode == 0 {
							return 0
						} else if runWordReturnCode == 1 {
							return 1
						} else if runWordReturnCode == 2 {
							print("Error running compiled word.")
							return 2
						} else {
							print("Error running compiled word.")
							return 2
						}
					} else if input == "compiler" {
						print(compiledWords)
					} else if input == ";" {
						print("not in compile mode")
					} else if compiledWords.contains(":::: " + input) && input != "" && compiled == true {
						let runWordReturnCode = runWord(word: input)
						if runWordReturnCode == 0 {
							return 0
						} else if runWordReturnCode == 1 {
						} else if runWordReturnCode == 2 {
							print("Error running compiled word.")
							return 2
						} else {
							print("Error running compiled word.")
							return 2
						}
					} else if compiledWords.contains(":::: " + input) && input != "" && compiled == false {
						let runWordReturnCode = runWord(word: input)
						if runWordReturnCode == 0 {
							return 0
						} else if runWordReturnCode == 1 {
						} else if runWordReturnCode == 2 {
							print("Error running compiled word.")
							return 2
						} else {
							print("Error running compiled word.")
							return 2
						}
					} else if input == "" {
					} else {
						print("no matching word in dictionary for: " + input)
					}
				}
			}
		}
	}
	return 1
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

func runWord(word: String) -> Int {
	let formattedWord: String = ":::: " + word + " "
	var fullDefinition: String.SubSequence = ""
	var definition: String.SubSequence = ""
	
	if let wordIndex = compiledWords.endIndex(of: formattedWord) {
		fullDefinition = compiledWords[wordIndex...]
	}
	if let wordIndex = fullDefinition.index(of: ";") {
		definition = fullDefinition[..<wordIndex]
	}
	//print(definition)
	
	let input_array = definition.components(separatedBy: " ")
	let returnCodeRW = processInput(input_array: input_array, compiled: true)
	
	if returnCodeRW == 1 {
		return 1
	} else if returnCodeRW == 2 {
		print("Error processing compiled word.")
		return 2
	} else if returnCodeRW == 0 {
		print("Compiled word contains 'bye'. Ending cruxForth.")
		return 0
	} else {
		print("Error processing compiled word.")
		return 2
	}
}

func clearCompiledWord(word: String) {
	let formattedWord: String = ":::: " + word + " "
	var fullDefinition: String.SubSequence = ""
	var definition: String.SubSequence = ""
	var toDelete: String.SubSequence = ""
	
	if let wordIndex = compiledWords.endIndex(of: formattedWord) {
		print("redefined " + word + ".")
		fullDefinition = compiledWords[wordIndex...]
		if let wordIndex = fullDefinition.index(of: ";") {
			definition = fullDefinition[..<wordIndex]
		}
		toDelete = formattedWord + definition + ";;;; "
		let newCompiledWords = compiledWords.replacingOccurrences(of: toDelete, with: "")
		compiledWords = newCompiledWords
	}
}

func lastCompiledWord() -> String {
	var fullDefinition: String.SubSequence = ""
	var definition: String.SubSequence = ""
	var wordNameString: String = ""
	
	if let wordIndex = compiledWords.lastIndex(of: ":") {
		fullDefinition = compiledWords[wordIndex...]
		if let wordIndex = fullDefinition.endIndex(of: ": ") {
			definition = fullDefinition[wordIndex...]
			let definition_array = definition.components(separatedBy: " ")
			wordNameString = definition_array[0]
		}
	}
	return wordNameString
}

func startComment() {
	commentFlag = true
}

func endComment() {
	commentFlag = false
}

func equal() {
	let topWord: Int = intStack.removeLast()
	let secondWord: Int = intStack.removeLast()
	if (topWord == secondWord) {
		intStack.append(-1)
	} else {
		intStack.append(0)
	}
}

func notEqual() {
	let topWord: Int = intStack.removeLast()
	let secondWord: Int = intStack.removeLast()
	if (topWord != secondWord) {
		intStack.append(-1)
	} else {
		intStack.append(0)
	}
}

func and() {
	let topWord: Int = intStack.removeLast()
	let secondWord: Int = intStack.removeLast()
	if (topWord == secondWord) {
		intStack.append(-1)
	} else {
		intStack.append(0)
	}
}

func or() {
	let topWord: Int = intStack.removeLast()
	let secondWord: Int = intStack.removeLast()
	if (topWord == -1 || secondWord == -1) {
		intStack.append(-1)
	} else {
		intStack.append(0)
	}
}

func greaterThan() {
	let topWord: Int = intStack.removeLast()
	let secondWord: Int = intStack.removeLast()
	if (secondWord > topWord) {
		intStack.append(-1)
	} else {
		intStack.append(0)
	}
}

func lessThan() {
	let topWord: Int = intStack.removeLast()
	let secondWord: Int = intStack.removeLast()
	if (secondWord < topWord) {
		intStack.append(-1)
	} else {
		intStack.append(0)
	}
}

func dup() {
	let topWord: Int = intStack.removeLast()
	intStack.append(topWord)
	intStack.append(topWord)
}

func swap() {
	let topWord: Int = intStack.removeLast()
	let secondWord: Int = intStack.removeLast()
	intStack.append(topWord)
	intStack.append(secondWord)
}

func twoDup() {
	let topWord: Int = intStack.removeLast()
	let secondWord: Int = intStack.removeLast()
	intStack.append(secondWord)
	intStack.append(topWord)
	intStack.append(secondWord)
	intStack.append(topWord)
}

func rot() {
	let topWord: Int = intStack.removeLast()
	let secondWord: Int = intStack.removeLast()
	let thirdWord: Int = intStack.removeLast()
	intStack.append(secondWord)
	intStack.append(topWord)
	intStack.append(thirdWord)
}

func evaluateStack() -> Int {
	if intStack.count > 0 {
		let topWord: Int = intStack.removeLast()
		if topWord < 0 {
			return 1
		} else {
			return 0
		}
	} else {
		print("no value on stack to compare.")
		return 2
	}
}

func processIfElse(stackEval: Int, index: Int, input_array: [String], compiled: Bool) -> [String] {
	var ifThenArray: [String] = []
	var ifInputArray = input_array
	var ifIndex: Int = 0
	// : bob 0 if 20 else 0 if 30 else 40 then then ;
	if compiled == true {
		switch stackEval {
		case 0:
			// top value was > -1, so consider as FALSE
			if let ifIndexPre = input_array.firstIndex(of: "if") {
				ifIndex = ifIndexPre
			} else {
				print("Error: no IF found.")
				return []
			}
			
			if let thenIndex = input_array.lastIndex(of: "then") {
				ifThenArray = Array(input_array[ifIndex...thenIndex])
			} else {
				print("Error: missing THEN clause.")
				return []
			}
			
			// handle nested if statements
			let ifCount = ifThenArray.filter{$0 == "if"}.count
			var thenIndices: [Int] = []
			var elseIndices: [Int] = []
			var ifIndices: [Int] = []
			var ifThenMap: [String] = []
			
			for (index, input) in input_array.enumerated() {
				if input == "then" {
					thenIndices.append(index)
					ifThenMap.append(input)
				} else if input == "else" {
					elseIndices.append(index)
					ifThenMap.append(input)
				} else if input == "if" {
					ifIndices.append(index)
					ifThenMap.append(input)
				}
			}
			
			let matchingThen = thenIndices[ifCount - 1]
			indicesToIgnore.append(matchingThen)
			ifInputArray[matchingThen] = ""
			
			if ifThenMap[1] == "if" {
				for each in 0...matchingThen - 1 {
					ifInputArray[each] = ""
					indicesToIgnore.append(each)
				}
			} else if ifThenMap[1] == "then" {
				for each in 0...matchingThen - 1 {
					ifInputArray[each] = ""
					indicesToIgnore.append(each)
				}
			} else if ifThenMap[1] == "else" {
				if let firstElse = ifInputArray.firstIndex(of: "else") {
					for each in 0...firstElse {
						indicesToIgnore.append(each)
						ifInputArray[each] = ""
					}
				}
			} else {
				print("Error with ifThenMap.")
				return []
			}
			
			return ifInputArray
						
		case 1:
			// TRUE
			print("if statement evaluated to TRUE")
			return ifInputArray
		case 2:
			print("error")
			return ifInputArray
		default:
			print("unsure")
			return ifInputArray
		}
	} else {
		print("Cannot interpret a compile-only word.")
		return []
	}
}
