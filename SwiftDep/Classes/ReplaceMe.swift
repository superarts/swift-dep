// import Foundation

public class SwiftDep {
	//	format: ["A B C", "B C E", ...]
	public class func test(array: [String]) {
		var items = [[String]]()
		var dict = [String: [String]]()
		for s in array {
			items.append(s.componentsSeparatedByString(" "))
		}
		print(items)
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
		for (key, value) in dict {
			resolve(key, value, &dict)
		}
		print(dict)
	}
	class func resolve(key: String, _ value: [String], inout _ dict: [String: [String]]) {
		print("resolving \(key), \(value)")
		for s in value {
			print("\(s), \(dict[s])")
			if let d = dict[s] {
				resolve(s, d, &dict)
			} else {
			}
		}
	}
}