public enum SDAddOrder: String {
	case Append
	case Insert
	case Ascending
	case Descending
	//	TODO: add custom sort
}

public class SwiftDep {
	public var dataSource: SDDataSource!
	public var order = SDAddOrder.Ascending
	public var allowsConflict = true

	public convenience init () {
		self.init(dataSource: SDDefaultDataSource())
	}
	public init (dataSource source: SDDataSource) {
		dataSource = source
	}

	/**
	 * in:	["B": ["C", "E"], "A": ["B", "C"], ...]
	 * Returns false if there's one or more conflict and it's not allowed
	 */
	public func setDependencyBatch(dict: [String: [String]]) -> Bool {
		dataSource.reset()

		var ret = true
		for (key, value) in dict {
			if !addDependency(key, value) {
				ret = false
			}
		}
		return ret
	}
	/**
	 * Add dependency [A: [B, C]] to dataSource.
	 * Returns false if there's a conflict and it's not allowed
	 */
	public func addDependency(key: String, _ value: [String]) -> Bool {
		//	add dependency to the new item
		var v = value
		for i in 0 ..< value.count {
			let k = value[i]
			if let dependency = dataSource[k] {
				SDHelper.addAndSort(&v, withArray: dependency, index: i + 1, order: order)
			}
		}
		if !allowsConflict {
			if v.contains(key) {
				//print("conflict \(key): \(v)")
				return false
			}
		}
		v = SDHelper.unique(v)
		//	add the new item to dataSource
		dataSource[key] = v
		//	update exising items in dataSource
		return dataSource.update(key, array: v, order: order, allowsConflict: allowsConflict)
	}
	public var all: [String: [String]] {
		return dataSource.getAll()
	}

	//	TODO: delete me
	public class func test(array: [String]) -> [String: String] {
		let sd = SwiftDep()
		let dict = SDHelper.stringToDictionary(array)
		sd.setDependencyBatch(dict)
		return SDHelper.dictionaryToKeyValue(sd.dataSource.getAll())
	}
}