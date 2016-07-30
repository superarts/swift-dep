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
		var keys = [String]()
		for (key, value) in dict {
			keys.append(key)
			//resolve(key, value, &dict)
			//resolve(key, value, dict)
		}
		for i in 1 ..< keys.count {
			resolve(keys[i], dict[keys[i]]!, &dict)
		}
		print(dict)
	}
	class func resolve(key: String, _ value: [String], inout _ dict: [String: [String]]) {
		print("resolving \(key), \(value)")
		var v = value
		for s in value {
			if dict[s] != nil {
				for s in dict[s]! {
					v.append(s)
				}
			}
		}
		//v.remove_duplicate()
		v = Array(Set(v))
		//print("TODO: remove duplicate \(v)")
		//print("updated value \(v)")
		dict[key] = v
		for (k1, v1) in dict {
			if v1.contains(key) {
				dict[k1]! += v
				//print("TODO: append \(k1) with \(v)")
				//dict[k1].remove_duplicate()
				dict[k1] = Array(Set(dict[k1]!))
				//print("TODO: remove duplicate \(dict[k1])")
			}
		}
		/*
		for s in value {
			//print("\(s), \(dict[s])")
			if let d = dict[s] {
				resolve(s, d, dict)
			} else {
			}
		}
		*/
	}
}