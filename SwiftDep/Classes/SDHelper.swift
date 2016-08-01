public struct SDHelper {
	public static var inputSeparator = " "
	public static var outputSeparator = " "
	
	static func unique<S : SequenceType, T : Hashable where S.Generator.Element == T>(source: S) -> [T] {
		var buffer = [T]()
			var added = Set<T>()
			for elem in source {
				if !added.contains(elem) {
					buffer.append(elem)
						added.insert(elem)
				}
			}
		return buffer
	}
	static func addAndSort(inout array: [String], withArray anotherArray: [String], order: SDAddOrder) {
		/*
		if order == .Insert {
			array.insertContentsOf(anotherArray, at: index)
		} else {
			array += anotherArray
		}
		*/
		array += anotherArray
		if order == .Ascending {
			array = array.sort {
				$0 < $1
			}
		} else if order == .Descending {
			array = array.sort() {
				$0 > $1
			}
		}
	}
	/**
	 * in:	[[A, B, C], [B, C, E], ...]
	 * out:	["B": ["C", "E"], "A": ["B", "C"], ...]
	 */
	public static func arrayToDictionary(items: [[String]]) -> [String: [String]] {
		var dict = [String: [String]]()
		for item in items {
			for s in item {
				if dict[s] == nil && item[0] == s {
					dict[s] = [String]()
				} else if let value = dict[item[0]] as [String]! {
					if !value.contains(s) {
						dict[item[0]]!.append(s)
					}
				}
			}
		}
		//print("arrayToDictionary: \(dict)")
		return dict
	}
	/**
	 * in:	["A B C", "B C E", ...]
	 * out:	[[A, B, C], [B, C, E], ...]
	 */
	public static func stringToArray(array: [String]) -> [[String]] {
		var items = [[String]]()
		for s in array {
			items.append(s.componentsSeparatedByString(inputSeparator))
		}
		//print("strToArray: \(items)")
		return items
	}
	/**
	 * in:	["A B C", "B C E", ...]
	 * out:	["B": ["C", "E"], "A": ["B", "C"], ...]
	 */
	public static func stringToDictionary(array: [String]) -> [String: [String]] {
		return arrayToDictionary(stringToArray(array))
	}
	/**
	 * in:	["B": ["C", "E"], "A": ["B", "C"], ...]
	 * out:	["B": "C E", "A": "B C", ...]
	 */
	public static func dictionaryToKeyValue(dict: [String: [String]]) -> [String: String] {
		var ret = [String: String]()
		for (key, value) in dict {
			ret[key] = value.joinWithSeparator(outputSeparator)
		}
		return ret
	}
}