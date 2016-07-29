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
    
    @IBOutlet weak var SearchButton: UIButton!
    @IBOutlet weak var SelectUniUiView: UIView!
    @IBOutlet weak var SelectTermUiView: UIView!
    @IBOutlet weak var SelectUniversityButton: UIButton!
    @IBOutlet weak var SelectTermButton: UIButton!
    let preferences = NSUserDefaults.standardUserDefaults()
    let preferredUniversityKey = "preferredUniversityKey"
    let preferredTermKey = "preferredTermKey"

    var selectedUniversity: Common.University?
    var selectedTerm: Common.Semester?
    
    override func viewDidLoad() {
        setupViews()
        updateSelectUniversityText()
    }

    func enableTermButton(enable: Bool) {
        if enable {
            SelectTermButton.enabled = true
            SelectTermUiView.alpha = 1
        } else {
            SelectTermButton.enabled = false
            SelectTermUiView.alpha = CGFloat(floatLiteral: 0.60)
        }
    }
    
    func enableSearchButton(enable: Bool) {
        if enable {
            SearchButton.enabled = true
            SearchButton.alpha = 1
        } else {
            SearchButton.enabled = false
            SearchButton.alpha = CGFloat(floatLiteral: 0.60)
        }
    }
    
    func setupViews() {
        enableSearchButton(false)
        enableTermButton(false)
        
        SelectTermButton.enabled = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
        SelectUniUiView.layer.cornerRadius = 10
        SelectTermUiView.layer.cornerRadius = 10
    }
    
    func setUniversity(university: Common.University) {
        selectedUniversity = university
        updateSelectUniversityText()
    }
    
    func setTerm(semester: Common.Semester) {
        selectedTerm = semester
        updateSelectTermText()
        
    }
    
    func updateSelectUniversityText() {
        if selectedUniversity == nil {
            setUniversityButtonText("Select a University")
        } else {
            let university = selectedUniversity!.name
            preferences.setObject(university, forKey: preferredUniversityKey)
            preferences.synchronize()
            setUniversityButtonText(university)
            enableTermButton(true)
        }
    }
    
    func updateSelectTermText() {
        if selectedUniversity == nil {
            setTermButtonText("Select a Term")
        } else {
            let term = Common.getReadableString(selectedTerm!)
            SelectTermButton.enabled = true
            preferences.setObject(term, forKey: preferredTermKey)
            preferences.synchronize()
            setTermButtonText(term)
            enableSearchButton(true)
        }
    }

    func setUniversityButtonText(text: String) {
        SelectUniversityButton.setTitle(text, forState: UIControlState.Normal)
    }
    
    func setTermButtonText(text: String) {
        SelectTermButton.setTitle(text, forState: UIControlState.Normal)
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
            nextViewController.loadedTerms = selectedUniversity?.availableSemesters
            nextViewController.searchProtocol = self
        }
        
        if segue.identifier == "gotoSubjectList" {
            let nextViewController = segue.destinationViewController as! SubjectsViewController
            nextViewController.selectedSemester = selectedTerm!
            nextViewController.selectedUniversity = selectedUniversity!
        }
    }
}