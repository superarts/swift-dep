// https://github.com/Quick/Quick

import Quick
import Nimble
import SwiftDep

class TableOfContentsSpec: QuickSpec {
    override func spec() {
		describe("SwiftDep") {
            it("can add dependency") {
				let sd = SwiftDep()
				sd.addDependency("A", ["B", "C"])
				sd.addDependency("B", ["C", "E"])

                expect(sd.all["A"]) == ["B", "C", "E"]
                expect(sd.all["B"]) == ["C", "E"]
            }
            context("reset dependency batch") {
				let sd = SwiftDep()
				it("can set dependency batch") {
					sd.setDependencyBatch(["A": ["B", "C"], "B": ["C", "E"]])

					expect(sd.all["A"]) == ["B", "C", "E"]
					expect(sd.all["B"]) == ["C", "E"]
				}
				it("can set dependency batch in a different way") {
					let dict = SDHelper.arrayToDictionary([["D", "E", "F"], ["E", "F", "G"]])
					sd.setDependencyBatch(dict)

					expect(sd.all["D"]) == ["E", "F", "G"]
					expect(sd.all["E"]) == ["F", "G"]
				}
				it("can set dependency batch and get result in the requested format") {
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
				}
			}
            context("dependency conflict") {
				let sd = SwiftDep()
				//	When addDependency() is called, item cannot be added if
				//	there's a conflict
				it("makes addDependency() returns false if there's a conflict and it's not allowed") {
					expect(sd.addDependency("A", ["B"])).to(beTrue())
					expect(sd.addDependency("B", ["C"])).to(beTrue())
					expect(sd.addDependency("C", ["A"])).to(beFalse())

					expect(sd.all["A"]) == ["B", "C"]
					expect(sd.all["B"]) == ["C"]
					expect(sd.all["C"]).to(beNil())
				}
				//	When setDependencyBatch() is called, items that cause
				//	conflict cannot be added, and it returns false if
				//	there's one or more conflict
				it("makes setDependencyBatch() returns false if there's one or more conflict and it's not allowed") {
					expect(sd.setDependencyBatch(["A": ["B"], "B": ["C"], "C": ["A"]])).to(beFalse())
					print("However, since Dictionary is not ordered, result cannot be predicted: \(sd.all)")
					print("TODO: if it's going to be a concern, Array [[Key: Value], ...] should be used instead of Dictionary [Key: Value, ...] as input format")
				}
			}
			context("performance") {
				it("is slow when dependency is deep") {
					let sd = SwiftDep()
					sd.order = .Append
					print("began: \(NSDate())")
					let count = 500
					for i in 0 ..< count {
						let s1 = String(format: "%09i", i)
						let s2 = String(format: "%09i", i + 1)
						sd.addDependency(s1, [s2])
					}
					expect(sd.all["000000000"]?.count) == count
					print("ended: \(NSDate())")
				}
				it("is a bit faster when dependency is not deep") {
					let sd = SwiftDep()
					sd.order = .Append
					print("began: \(NSDate())")
					let count = 10000
					for i in 0 ..< count {
						let s1 = String(format: "%09i", i)
						let s2 = "x"
						sd.addDependency(s1, [s2])
					}
					expect(sd.all["000000000"]?.count) == 1
					print("ended: \(NSDate())")
				}
				it("is very slow when using SDSmallDataSource") {
					let sd = SwiftDep(dataSource: SDSmallDataSource())
					sd.order = .Append
					print("began: \(NSDate())")
					let count = 400
					for i in 0 ..< count {
						let s1 = String(format: "%09i", i)
						let s2 = String(format: "%09i", i + 1)
						sd.addDependency(s1, [s2])
					}
					expect(sd.all["000000000"]?.count) == count
					print("ended: \(NSDate())")
				}
			}
            context("order") {
				it("can append dependency") {
					let sd = SwiftDep()
					sd.order = .Append
					sd.addDependency("A", ["D", "C"])
					sd.addDependency("D", ["E", "F"])
					expect(sd.all["A"]) == ["D", "C", "E", "F"]
				}
				it("can order dependency ascendingly by default, which is slow") {
					let sd = SwiftDep()
					sd.addDependency("A", ["D", "C"])
					sd.addDependency("D", ["E", "F"])
					expect(sd.all["A"]) == ["C", "D", "E", "F"]
				}
				it("can also order dependency descendingly") {
					let sd = SwiftDep()
					sd.order = .Descending
					sd.addDependency("A", ["D", "C"])
					sd.addDependency("D", ["E", "F"])
					expect(sd.all["A"]) == ["F", "E", "D", "C"]
				}
			}
			it("can use another data source") {
				//	TODO: implement other data sources
			}
		}
    }
}