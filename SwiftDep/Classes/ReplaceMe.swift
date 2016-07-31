// import Foundation

public class SwiftDep {
	public class func test(array: [String]) -> [String: [String]] {
		let a1 = strToArray(array)
		var dict = arrayToDictionary(a1)
		addDependencyBatch(&dict)
		return dict
	}
	//	in:		["A B C", "B C E", ...]
	//	out:	[[A, B, C], [B, C, E], ...]
	public class func strToArray(array: [String]) -> [[String]] {
		var items = [[String]]()
		for s in array {
			items.append(s.componentsSeparatedByString(" "))
		}
		print("strToArray: \(items)")
		return items
	}
	//	in:		[[A, B, C], [B, C, E], ...]
	//	out:	["B": ["C", "E"], "A": ["B", "C"], ...]
	public class func arrayToDictionary(items: [[String]]) -> [String: [String]] {
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
		print("arrayToDictionary: \(dict)")
		return dict
	}
	//	in:		["B": ["C", "E"], "A": ["B", "C"], ...]
	//	out:	resolved result
	public class func addDependencyBatch(inout dict: [String: [String]]) -> [String: [String]] {
		var keys = [String]()
		for (key, value) in dict {
			keys.append(key)
		}
		for i in 1 ..< keys.count {
			addDependency(keys[i], dict[keys[i]]!, &dict)
			print("adding dependency \(keys[i]): \(dict[keys[i]]!)")
		}
		return dict
	}
	//	add dependency [A: [B, C]] to dataSource
	class func addDependency(key: String, _ value: [String], inout _ dict: [String: [String]]) {
		var v = value
		for s in value {
			if dict[s] != nil {
				for s in dict[s]! {
					v.append(s)
				}
			}
		}
		v = Array(Set(v))
		dict[key] = v
		for (k1, v1) in dict {
			if v1.contains(key) {
				dict[k1]! += v
				dict[k1] = Array(Set(dict[k1]!))
			}
		}
	}
}