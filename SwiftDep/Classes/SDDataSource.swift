public protocol SDDataSource {
	/**
	 * Initialize dataSource with `dict`. Pass `nil` to clear.
	 */
	func reset(dict: [String: [String]]?)
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
 * A pseudo-dataSource that is based on Sqlite.
 */
public class SDSqliteDataSource: SDDataSource {
	var filename: String!
	public func reset(aDict: [String: [String]]?) {
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