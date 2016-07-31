# SwiftDep

A Swift library that analyzes simple dependencies.

## Install

This pod is not published yet. To debug, add this line in your `Podfile`:

`pod 'LCategory', :git => 'git@github.com:superarts/swift-dep.git'`

## Example & Test

Instead of installing the `pod` in your project, probably you'd like to take a look at the `Tests` in `Example`:

- `git clone git@github.com:superarts/swift-dep.git`
- `cd swift-dep/Example`
- `open SwiftDep.xcworkspace`
- `<Command + U>`

## Usage

Check `Tests.swift` for all the test cases.

### Basic

After `import SwiftDep`, call `addDependency()` to add a new item, and use `all` to access results:

```
	let sd = SwiftDep()
	sd.addDependency("A", ["B", "C"])
	sd.addDependency("B", ["C", "E"])

	expect(sd.all["A"]) == ["B", "C", "E"]
	expect(sd.all["B"]) == ["C", "E"]
```

You can also use `setDependencyBatch()` to setup data from a dictionary with format `[key: [dependency list]]`, note that all previous data will be reset in this way:

```
	sd.setDependencyBatch(["A": ["B", "C"], "B": ["C", "E"]])
```

### Helper Formatter

To support format in the requirement document, some helper functions can be used to format input and output data:

```
	let dict = SDHelper.stringToDictionary([
		"A B C",
		"B C E",
		"C G",
		"D A F",
		"E F",
		"F H",
	])
	sd.setDependencyBatch(dict)

	let result = SDHelper.dictionaryToKeyValue(sd.all)
	expect(result["A"]) == "B C E F G H"
	expect(result["B"]) == "C E F G H"
	expect(result["C"]) == "G"
	expect(result["D"]) == "A B C E F G H"
	expect(result["E"]) == "F H"
	expect(result["F"]) == "H"
```

Among helper functions `arrayToDictionary`, `stringToArray`, `stringToDictionary`, and `dictionaryToKeyValue`, for item `A` with dependency `B` and `C`, here's a list to show what is expected when converting:

- `string`: `["A B C", ...]`
- `array`: `[[A, B, C], ...]`
- `dictionary`: `[A: [B, C]], ...]`
- `keyValue`: `[A: "B C", ...]`

And `dictionary` is used internally. Here it is assumed that for data like [A: [B], B: [C]], order of A and B is not important. However, if this is not going to be the case for some reason, `[A: [B, C]], ...]` should be replaced with `[[A: [B, C]], ...]`.

### Dependency Conflict

By default, dependency conflict is allowed:

```
	let sd = SwiftDep()
	sd.addDependency("A", ["B"])
	sd.addDependency("B", ["C"])
	sd.addDependency("C", ["A"])

	expect(sd.all["A"]) == ["A", "B", "C"]
	expect(sd.all["B"]) == ["A", "B", "C"]
	expect(sd.all["C"]) == ["A", "B", "C"]
```

Such behavior can be changed by setting `sd.allowsConflict = false`, and in this case, `addDependency()` will stop working and return `false` if the new item conflicts with others:

```
	expect(sd.addDependency("A", ["B"])).to(beTrue())
	expect(sd.addDependency("B", ["C"])).to(beTrue())
	expect(sd.addDependency("C", ["A"])).to(beFalse())

	expect(sd.all["A"]) == ["B", "C"]
	expect(sd.all["B"]) == ["C"]
	expect(sd.all["C"]).to(beNil())
```

`setDependencyBatch()` is also going to return `false` if there's conflict. However, as discussed above, since input dictionary is not ordered, the whole result is not reliable. In this case, when it's guaranteed that the input dictionary will be set, and the following operations is unpredictable.

```
	expect(sd.setDependencyBatch(["A": ["B"], "B": ["C"], "C": ["A"]])).to(beFalse())
```

### About Result Order

```
	public enum SDAddOrder: String {
		case Append
		case Insert
		case Ascending
		case Descending
		//	TODO: add custom sort
	}
```

`order` can be set to `.Append` to append new dependencies to the old dependency list, you can think it works in a way that all the new dependencies come last (it's also faster):

```
	let sd = SwiftDep()
	sd.order = .Append
	sd.addDependency("A", ["D", "C"])
	sd.addDependency("D", ["E", "F"])
	expect(sd.all["A"]) == ["D", "C", "E", "F"]
```

By setting `order` to `.Insert`, dependencies stick close to each other in a hereditary manner:

```
	let sd = SwiftDep()
	sd.order = .Insert
	sd.addDependency("A", ["D", "C"])
	sd.addDependency("D", ["E", "F"])
	expect(sd.all["A"]) == ["D", "E", "F", "C"]
```

However, in the requirment it's obviously not `.Insert` for almost all cases, and for item `D A F`, it became `D ABCEFGH` so it's not `.Append` either. To make result as required format, `.Ascending` and `.Decending` are added and `.Asending` is set as default. It does a `sort` though, which introduces additional `O(log n)` complexity.

### Performance

The current implementation is based on the idea that new dependencies can be appended and analyzed, instead of having everything beforehand and analyzing them altogether. An `SDDataSource` is required to handle data store in different ways. The `SDDefaultDataSource` is a data source that uses a dictionary to store all the information, which uses `subscript` to `get` and `set`, `indexOf` to check, and `insertContentsOf` to insert and `+` append.

It is the most straight-forward way, and to make it scalable, there's also a pseudo `SDSqliteDataSource` to show how to do it in a `RDB` way: setting up a table with `key`s and `value`s, and querying `key` to construct the actual object (all `value`s are dependencies). Of course, if we use `NoSQL` solutions, it will work more like the `SDDefaultDataSource` since we can use an array as `value`, and use `contains` to query. All these solutions can be implemented on a backend service and access via API endpoints.

However, it turned out that the whole idea may not work after all: it doesn't seem to be able to handle millions of items in a reasonable time, because currently it's impossible to solve the problem in a distributive way, due to the fact that each time `SDDataSource.update()`, the operation needs to be atomic. This is going to be the biggest concern, and eventually I might end up like a giant retard that's bad at algorithm.