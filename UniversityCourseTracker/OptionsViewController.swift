//
//  ViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit


class OptionsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    var university: Common.University?
    var universityPickerView: UIPickerView?
    var universities = Array<Common.University>()
    var selectedUniversityIndex: Int?
    var selectedUniversity: Common.University?
    
    var terms = Array<Common.Semester>()
    
    var selectedTermIndex: Int?
    var termPickerView: UIPickerView?

    
    @IBOutlet weak var universityLabel: UILabel!
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var universityTextField: UITextField!
    @IBOutlet weak var termTextField: UITextField!
    
    @IBAction func doneClicked(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            universityTextField.becomeFirstResponder()
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        } else {
            termTextField.becomeFirstResponder()
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            
            // Populate with current university
            populateTerms(selectedUniversity!)
        }
        // Disable modal return button
        navigationItem.rightBarButtonItem?.enabled = false

    }
    
    func populateTerms(university: Common.University) {
        terms.removeAll()
        for semester in university.availableSemesters {
            terms.append(semester)
        }
        termPickerView?.reloadAllComponents()
    }
    
    override func viewDidLoad() {
        setupViews()
        loadData()
    }
    
    func loadData() {
        appDelegate.dataRepo?.getUniversity(userDefaults.universityTopicName, {
            [weak self] university in
            if let university = university {
                self?.university = university
                self?.setupViews()
            } else {
                NSLog("Error getting university " + (self?.userDefaults.universityTopicName)!)
            }
        })
        
        appDelegate.dataRepo?.getUniversities({
            [weak self] universities in
            if let universities = universities {
                self?.universities = universities
                self?.universityPickerView?.reloadAllComponents()
            } else {
                NSLog("Error getting universities " + (self?.userDefaults.universityTopicName)!)
            }
            
        })
    }
    
    func setupViews() {
        // !!Possible syncronization issues
        selectedUniversity = appConfig.university
        populateTerms(selectedUniversity!)
        
        setSelectUniversityText(selectedUniversity!.name)
        setSelectTermText(userDefaults.season.capitalizedString + " " + userDefaults.year)
        
        setupUniversityPickerView()
        setupTermPickerView()
    }
    
    func setupUniversityPickerView() {
        universityPickerView = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 200))
        universityPickerView!.backgroundColor = .whiteColor()
        universityPickerView!.showsSelectionIndicator = true
        universityPickerView!.dataSource = self
        universityPickerView!.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = false
        toolBar.tintColor = self.primaryColor
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(OptionsViewController.doneUniversityPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(OptionsViewController.cancelUniversityPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        universityTextField.inputView = universityPickerView
        universityTextField.inputAccessoryView = toolBar
    }

    func doneUniversityPicker(sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.enabled = true
        universityTextField.resignFirstResponder()
        selectedUniversityIndex = universityPickerView?.selectedRowInComponent(0)
        selectedUniversity = universities[selectedUniversityIndex!]
        
        // Save selected university
        userDefaults.universityTopicName = selectedUniversity!.topicName
        
        // Populate terms with latest university, reset default term
        populateTerms(selectedUniversity!)
        userDefaults.season = selectedUniversity!.resolvedSemesters.current.season
        userDefaults.year = selectedUniversity!.resolvedSemesters.current.year.description
        
        setSelectUniversityText(selectedUniversity!.name)
        setSelectTermText(selectedUniversity!.resolvedSemesters.current)
    }

    func cancelUniversityPicker(sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.enabled = true
        universityTextField.resignFirstResponder()
    }
    
    func setupTermPickerView() {
        termPickerView = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 200))
        termPickerView!.backgroundColor = .whiteColor()
        termPickerView!.showsSelectionIndicator = true
        termPickerView!.dataSource = self
        termPickerView!.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = false
        toolBar.tintColor = self.primaryColor
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(OptionsViewController.doneTermPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(OptionsViewController.cancelTermPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        termTextField.inputView = termPickerView
        termTextField.inputAccessoryView = toolBar
    }
    
    func doneTermPicker(sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.enabled = true
        termTextField.resignFirstResponder()
        selectedTermIndex = termPickerView?.selectedRowInComponent(0)

        let selectedSemester = selectedUniversity!.availableSemesters[selectedTermIndex!]
        
        // Save selected term
        userDefaults.season = selectedSemester.season
        userDefaults.year = selectedSemester.year.description
        setSelectTermText(selectedSemester)
    }
    
    func cancelTermPicker(sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.enabled = true
        termTextField.resignFirstResponder()
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == universityPickerView {
            return universities[row].name
        } else {
            return Common.getReadableString(terms[row])
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == universityPickerView {
            return universities.count
        } else {
            return terms.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == universityPickerView {
            selectedUniversityIndex = row
        } else {
            selectedTermIndex = row
        }
    }
    
    func setSelectUniversityText(text: String) {
        universityLabel.text = text
    }
    
    func setSelectTermText(semester: Common.Semester) {
        termLabel.text = Common.getReadableString(semester)
    }
    
    func setSelectTermText(semester: String) {
        termLabel.text = semester
    }
}