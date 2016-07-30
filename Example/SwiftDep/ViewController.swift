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
		SwiftDep.test([
			"A B C",
			"B C E",
			"C G",
			"D A F",
			"E F",
			"F H",
		])
		SwiftDep.test([
			"A B",
			"B C",
			"C A",
		])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}