//
//  ViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func DoShit(sender: AnyObject) {
        getUniversities{ (uni : Array<Common.University>?) in
            if let university = uni {
                for a in university {
                }
            } else {
                print("Error")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}