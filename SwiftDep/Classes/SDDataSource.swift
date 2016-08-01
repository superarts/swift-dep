public protocol SDDataSource {
	/**
	 * Clear dataSource
	 */
	func reset()
	/**
	 * Update all dependencies with [key: array] 
	 * Returns false if there's a conflict and it's not allowed
	 */
	func update(key: String, array: [String], order: SDAddOrder, allowsConflict: Bool) -> Bool
	/**
	 * Get all dependencies
	 */
	func getAll() -> [String: [String]]

	func get(key: String) -> [String]?
	func set(key: String, array: [String]?)
}

extension SDDataSource {
	/**
	 * Use subscript to get and set
	 */
	public subscript(key: String) -> [String]? { 
		get {
			return get(key)
		}
		set(array) {
			set(key, array: array)
		}
	}
}

/**
 * The default SwiftDep dataSource
 */
typealias SDDefaultDataSource = SDSmallDataSource

/**
 * A simple dataSource, which is based on a native Dictionary.
 * It only uses a small amount of memomry so it's quite slow.
 */
public class SDSmallDataSource: SDDataSource {
	var dict = [String: [String]]()
	public func reset() {
		dict.removeAll()
	}
	public func get(key: String) -> [String]? {
		return dict[key]
	}
	public func set(key: String, array: [String]?) {
		dict[key] = array
	}
	public func update(key: String, array: [String], order: SDAddOrder, allowsConflict: Bool) -> Bool {
		for (k, v) in dict {
			if let index = v.indexOf(key) {
				if !allowsConflict {
					if array.contains(k) {
						return false
					}
				}
				SDHelper.addAndSort(&dict[k]!, withArray: array, index: index + 1, order: order)
				dict[k] = SDHelper.unique(dict[k]!)
			}
		}
		return true
	}
	public func getAll() -> [String: [String]] {
		return dict
	}
}

/**
 * A faster dataSource, which stores parents in memory.
 */
public class SDFastDataSource: SDSmallDataSource {
	var parent = [String: [String]]()
	public override func reset() {
		super.reset()
		parent.removeAll()
	}
	public override func set(key: String, array: [String]?) {
		super.set(key, array: array)
		dict[key] = array
		if let a = array {
			for value in a {
				if parent[value] == nil {
					parent[value] = [key]
				} else {
					parent[value]!.append(key)
				}
			}
		}
	}
	public override func update(key: String, array: [String], order: SDAddOrder, allowsConflict: Bool) -> Bool {
		if let keys = parent[key] {
			for k in keys {
				if !allowsConflict {
					if array.contains(k) {
						return false
					}
				}
				SDHelper.addAndSort(&dict[k]!, withArray: array, index: 0, order: order)
				dict[k] = SDHelper.unique(dict[k]!)
			}
		}
		return true
	}
}

/**
 * A pseudo-dataSource that is based on Sqlite.
 */
public class SDSqliteDataSource: SDDataSource {
	var filename: String!
	public func reset() {
		/*
		 * delete_db
		 * create_db
		 * CREATE TABLE Relationship(Key, Value);
		 */
	}
	public func get(key: String) -> [String]? {
		/*
		 * results = SELECT Value FROM Relationship WHERE Key = key;
		 * return results
		 */
		return nil
	}
	public func set(key: String, array: [String]?) {
		/*
		 * FOREACH value IN array
		 *	INSERT INTO Relationship (Key, Value) VALUES (key, value);
		 */
	}
	public func update(key: String, array: [String], order: SDAddOrder, allowsConflict: Bool) -> Bool {
		/*
		 * keys = SELECT Key FROM Relationship WHERE Value = key;
		 * FOREACH aKey IN keys
		 *	FOREACH aValue IN array
		 *	 INSERT INTO Relationship (Key, Value) VALUES (aKey, aValue);
		 */
		return false
	}
	public func getAll() -> [String: [String]] {
		/* 
		 * results = []
		 * keys = SELECT keys FROM table
		 * FOREACH key IN keys
		 *	results.append(SELECT Value FROM Relationship where Key = key)
		 */
		return [String: [String]]()
	}
}