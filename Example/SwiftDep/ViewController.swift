//
//  ViewController.swift
//  SwiftDep
//
//  Created by Leo on 07/30/2016.
//  Copyright (c) 2016 Leo. All rights reserved.
//

import UIKit
import SwiftDep

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		print(SwiftDep.test([
			"A B C",
			"B C E",
			"C G",
			"D A F",
			"E F",
			"F H",
		]))
		print(SwiftDep.test([
			"A B",
			"B C",
			"C A",
		]))

		let sd = SwiftDep()
		sd.addDependency("A", ["B", "C"])
		sd.addDependency("B", ["C", "E"])
		print(sd.all)

		print("began: \(NSDate())")
		var array1 = ["test1"]
		let array2 = ["test2"]
		for _ in 0 ..< 1000000 {
			array1 += array2
		}
		print("ended: \(NSDate()), \(array1.count)")

		print("began: \(NSDate())")
		for s in array1 {
			doNothing(s)
		}
		print("ended: \(NSDate()), \(array1.count)")
    }
	func doNothing(s: String) {
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}