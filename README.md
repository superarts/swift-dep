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

When dependency conflict occurs, i.e. trying insert [B: [A]] after [A: [B]], `addDependency()` will stop working and return `false` if the new item conflicts with others:

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

Previously, by setting `order` to `.Insert`, dependencies stick close to each other in a hereditary manner:

```
	let sd = SwiftDep()
	sd.order = .Insert
	sd.addDependency("A", ["D", "C"])
	sd.addDependency("D", ["E", "F"])
	expect(sd.all["A"]) == ["D", "E", "F", "C"]
```

This feature has been move to improve performance.

However, in the requirment it's obviously not `.Insert` for almost all cases, and for item `D A F`, it became `D ABCEFGH` so it's not `.Append` either. To make result as required format, `.Ascending` and `.Decending` are added and `.Asending` is set as default. It does a `sort` though, which introduces an additional `O(log n)` complexity.

### Performance

The current implementation is based on the idea that new dependencies can be appended and analyzed, instead of having everything beforehand and analyzing them altogether. An `SDDataSource` is required to handle data store in different ways. The `SDSmallDataSource` is a DataSource that uses a dictionary to store all the information, which uses `subscript` to `get` and `set`, `indexOf` to check, and `insertContentsOf` to insert and `+` append. It requires minimum memory usage but is quite slow, and there's another `SDFastDataSource` stores parents of different elements and makes it about 10x faster. It is the `SDDefaultDataSource` in the current version.

It is the most straight-forward way, and to make it scalable, there's also a pseudo `SDSqliteDataSource` to show how to do it in a `Relational` way: setting up a table with `key`s and `value`s, and querying `key` to construct the actual object (all `value`s are dependencies). Of course, if we use `NoSQL` solutions, it will work more like the `SDDefaultDataSource` since we can use an array as `value`, and use `contains` to query. All these solutions can be implemented on a backend service and access via API endpoints.

Currently performance is still a big problem. In the following test case:

```
	let sd = SwiftDep()
	sd.order = .Append
	let count = 500
	for i in 0 ..< count {
		let s1 = String(format: "%09i", i)
		let s2 = String(format: "%09i", i + 1)
		sd.addDependency(s1, [s2])
	}
	expect(sd.all["000000000"]?.count) == count
```

Where the new item always depends on the previous one, it takes about `x^2/2` operations to proceed, and runs quite slow. Unfortunately changing `Swift Optimization Level` doesn't help much. 

However, we do know that performance can be highly enhanced by rewriting in `Objective-C`, or even C (the PHP extension I've written that joins video together was implemented in pure C and it worked pretty well for large quantity of data). Although [Swift can be as fast as C in some cases like quick sort](http://stackoverflow.com/questions/24101718/swift-performance-sorting-arrays), it is also known that [ObjC string is 100x faster than Swift](http://stackoverflow.com/questions/26990394/slow-swift-arrays-and-strings-performance). Since the most time consuming task is something like:

```
	public override func update(key: String, array: [String], order: SDAddOrder) {
		if let keys = parent[key] {
			for k in keys {
				SDHelper.addAndSort(&dict[k]!, withArray: array, order: order)
				update(k, array: array, order: order)
			}
		}
	}
```

Firstly I've tried to test performance of appending arrays, here's the `Swift` version:

```
	var array1 = ["test1"]
	let array2 = ["test2"]
	for _ in 0 ..< 100000000 {
		array1 += array2
	}
```

And the `Objective-C` equivalent:

```
	NSMutableArray* array1 = [@[@"test1"] mutableCopy];
	NSArray* array2 = @[@"test2"];
	for (int i = 0; i < 123456789; i++)
		[array1 addObjectsFromArray:array2];
```

`Swift` takes about 60-62 seconds while `Objective-C` version takes 8 seconds. I also tested looping through an array and making function calls:

```
	for s in array1 {
		doNothing(s)
	}
```

And:

```
	for (NSString* s in array1)
		[self doNothing:s];
```

Again, `Swift` takes 20 seconds while `Objective-C` only takes 1.5 second. I'm not denying the fact that I'm pretty bad at algorithms, but for this task, using `Objective-C` can hopefully make it 50x faster, which makes it possible to handle half a million operations in a second. Implementing a relational DataSource is also a promising direction, and that will make it scalable. But in the end I should read more to see how it's handled in other projects.