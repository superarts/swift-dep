// import Foundation

public protocol SDDataSource {
	func reset(dict: [String: [String]]?)
	func get(key: String) -> [String]?
	func set(key: String, array: [String]?)
	func update(key: String, array: [String])
	func getAll() -> [String: [String]]
}

extension SDDataSource {
	public subscript(key: String) -> [String]? { 
		get {
			return get(key)
		}
		set(array) {
			set(key, array: array)
		}
	}
	public func clear() {
		reset(nil)
	}
}

/**
 * The default SwiftDep dataSource, which is based on a native Dictionary.
 */
public class SDDefaultDataSource: SDDataSource {
	var dict = [String: [String]]()
	public func reset(aDict: [String: [String]]?) {
		if let d = aDict {
			dict = d
		} else {
			dict.removeAll()
		}
	}
	public func get(key: String) -> [String]? {
		return dict[key]
	}
	public func set(key: String, array: [String]?) {
		dict[key] = array
	}
	public func update(key: String, array: [String]) {
		for (k1, v1) in dict {
			if v1.contains(key) {
				dict[k1]! += array
				dict[k1] = Array(Set(dict[k1]!))
			}
		}
	}
	public func getAll() -> [String: [String]] {
		return dict
	}
}

public class SwiftDep {
	var dataSource: SDDataSource!
	public class func test(array: [String]) -> [String: String] {
		let sd = SwiftDep(dataSource: SDDefaultDataSource())
		let a1 = sd.strToArray(array)
		var dict = sd.arrayToDictionary(a1)
		sd.addDependencyBatch(dict)
		return sd.valueArrayToString(sd.dataSource.getAll())
	}
	/*
	init () {
		init(_ dataSource: SDDefaultDataSource())
	}
	*/
	init (dataSource source: SDDataSource) {
		dataSource = source
	}
	//	in:		["A B C", "B C E", ...]
	//	out:	[[A, B, C], [B, C, E], ...]
	public func strToArray(array: [String]) -> [[String]] {
		var items = [[String]]()
		for s in array {
			items.append(s.componentsSeparatedByString(" "))
		}
		print("strToArray: \(items)")
		return items
	}
	//	in:		[[A, B, C], [B, C, E], ...]
	//	out:	["B": ["C", "E"], "A": ["B", "C"], ...]
	public func arrayToDictionary(items: [[String]]) -> [String: [String]] {
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
	public func addDependencyBatch(dict: [String: [String]]) {
		dataSource.reset(dict)
		var keys = [String]()
		for (key, value) in dict {
			keys.append(key)
		}
		for i in 1 ..< keys.count {
			print("adding dependency \(keys[i]): \(dict[keys[i]]!)")
			addDependency(keys[i], dict[keys[i]]!)
		}
		print("addDependencyBatch: \(dataSource.getAll())")
	}
	//	add dependency [A: [B, C]] to dataSource
	public func addDependency(key: String, _ value: [String]) {	//, inout _ dict: [String: [String]]) {
		//	add dependency to the new item
		var v = value
		for s in value {
			if let dependency = dataSource[s] {
				v += dependency
			}
			/*
			if dict[s] != nil {
				for s in dict[s]! {
					v.append(s)
				}
			}
			*/
		}
		v = Array(Set(v))
		//	add the new item to dataSource
		dataSource[key] = v
		/*
		dict[key] = v
		*/
		//	update dataSource
		dataSource.update(key, array: v)
		/*
		for (k1, v1) in dict {
			if v1.contains(key) {
				dict[k1]! += v
				dict[k1] = Array(Set(dict[k1]!))
			}
		}
		*/
	}
	//	in:		["B": ["C", "E"], "A": ["B", "C"], ...]
	//	out:	["B": ["C E"], "A": ["B C"], ...]
	public func valueArrayToString(dict: [String: [String]]) -> [String: String] {
		var ret = [String: String]()
		for (key, value) in dict {
			ret[key] = value.joinWithSeparator(" ")
		}
		return ret
	}
}