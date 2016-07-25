//
//  ViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

protocol SearchFlowProtocol {
    func setUniversity(university: Common.University)
    func setTerm(semester: Common.Semester)
}

class SearchViewController: UIViewController, SearchFlowProtocol {
    
    @IBOutlet weak var SelectUniUiView: UIView!
    @IBOutlet weak var SelectTermUiView: UIView!
    @IBOutlet weak var SelectUniversityButton: UIButton!
    @IBOutlet weak var SelectTermButton: UIButton!
    let preferences = NSUserDefaults.standardUserDefaults()
    let preferredUniversityKey = "preferredUniversityKey"
    let preferredTermKey = "preferredTermKey"

    var selectedUniversity: Common.University?
    var selectedTerm: Common.Semester?
    
    func updateSelectUniversityText() {
        if selectedUniversity == nil {
            if preferences.objectForKey(preferredUniversityKey) == nil {
                setUniversityButtonText("Select a University")
            } else {
                setUniversityButtonText(preferences.stringForKey(preferredUniversityKey)!)
            }
        } else {
            let university = selectedUniversity!.name
            preferences.setObject(university, forKey: preferredUniversityKey)
            preferences.synchronize()
            setUniversityButtonText(university)
        }
    }
    
    func updateSelectTermText() {
        if selectedUniversity == nil {
            if preferences.objectForKey(preferredTermKey) == nil {
                setTermButtonText("Select a Term")
            } else {
                setTermButtonText(preferences.stringForKey(preferredTermKey)!)
            }
        } else {
            let term = Common.getReadableString(selectedTerm!)
            preferences.setObject(term, forKey: preferredTermKey)
            preferences.synchronize()
            setTermButtonText(term)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateSelectUniversityText()
        
        getUniversities { (unis: Array<Common.University>?) in
            if let unis = unis {
                var universityList: [String] = []
                for u in unis {
                    universityList.append(u.name)
                }
            } else {
                print("Error")
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    func setupViews() {
        SelectTermButton.enabled = false
        SelectUniUiView.layer.cornerRadius = 10
        SelectTermUiView.layer.cornerRadius = 10
    }
    
    func setUniversity(university: Common.University) {
        selectedUniversity = university
        updateSelectUniversityText()
        SelectTermButton.enabled = true
    }
    
    func setTerm(semester: Common.Semester) {
        selectedTerm = semester
        updateSelectTermText()
    }
    
    func setUniversityButtonText(text: String) {
        SelectUniversityButton.setTitle(text, forState: UIControlState.Normal)
    }
    
    func setTermButtonText(text: String) {
        SelectTermButton.setTitle(text, forState: UIControlState.Normal)
    }


    @IBAction func SelectUniversityButton(sender: AnyObject) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoUniversityList" {
            let nextViewController = segue.destinationViewController as! UniversityListViewController
            nextViewController.searchProtocol = self
        }
        
        if segue.identifier == "gotoTermList" {
            let nextViewController = segue.destinationViewController as! TermViewController
            nextViewController.setAvailableSemesters((selectedUniversity?.availableSemesters)!)
            nextViewController.searchProtocol = self
        }
    }
}