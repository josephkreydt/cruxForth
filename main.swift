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
var controlFlowStack: [Bool] = []

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
	var currentNestIsReadable: Bool = true
	for (index, input) in input_array.enumerated() {
		if let x = controlFlowStack.last {
			currentNestIsReadable = x
		}
		if currentNestIsReadable {
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
						ifIf()
					} else if input == "else" {
						ifElse()
					} else if input == "then" {
						ifThen()
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
		} else {
			if commentFlag == false {
				if input == "if" {
					ifIf()
				} else if input == "else" {
					ifElse()
				} else if input == "then" {
					ifThen()
				} else if input == "bye" {
					return 0
				} else if input == "show" {
					print(intStack)
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

func ifIf() {
	var conditionBool: Bool
	var currentNestIsReadable: Bool
	if controlFlowStack.count > 0 {
		if let x = controlFlowStack.last {
			currentNestIsReadable = x
		} else {
			print("Error with control flow stack value checking on IF.")
			return
		}
		if currentNestIsReadable {
			if intStack.count > 0 {
				let conditionValue = intStack.removeLast()
				if conditionValue > -1 {
					conditionBool = false
				} else {
					conditionBool = true
				}
			} else {
				print("No value on integer stack. Using value of current nest.")
				conditionBool = currentNestIsReadable
			}
		} else {
			conditionBool = false
		}
	} else {
		if intStack.count > 0 {
			let conditionValue = intStack.removeLast()
			if conditionValue > -1 {
				conditionBool = false
			} else {
				conditionBool = true
			}
		} else {
			print("No value on integer stack. Assuming -1 (TRUE).")
			conditionBool = true
		}
	}
	controlFlowStack.append(conditionBool)
}

func ifElse() {
	var currentNestIsReadable: Bool
	var parentNestIsReadable: Bool
	if controlFlowStack.count > 0 {
		if let x = controlFlowStack.last {
			currentNestIsReadable = x
			if currentNestIsReadable {
				if x == true {
					controlFlowStack.removeLast()
					controlFlowStack.append(false)
				} else {
					controlFlowStack.removeLast()
					controlFlowStack.append(true)
				}
			} else {
				if controlFlowStack.count > 1 {
					let secondToLast = controlFlowStack.count - 2
					if controlFlowStack[secondToLast] {
						parentNestIsReadable = true
					} else {
						parentNestIsReadable = false
					}
					
					if parentNestIsReadable {
						controlFlowStack.removeLast()
						controlFlowStack.append(true)
					} else {
						
					}
				} else {
					controlFlowStack.removeLast()
					controlFlowStack.append(true)
				}
			}
		} else {
			print("Error: unable to read last value on control flow stack.")
			return
		}
	} else {
		print("Error: No value on control flow stack. ELSE should preceded by IF.")
		return
	}
}

func ifThen() {
	if controlFlowStack.count > 0 {
		controlFlowStack.removeLast()
	} else {
		print("Error: control flow stack is empty. THEN should be preceded by IF or ELSE.")
		return
	}
}
