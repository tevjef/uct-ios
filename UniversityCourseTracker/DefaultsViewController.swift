//
//  DefaultsViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/30/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit
import Foundation

class DefaultsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var letsGoButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    var indicator = UIActivityIndicatorView()
    var pickerView: UIPickerView?
    var universities: Array<Common.University>?
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        // Skip vc if user has selected a default university
        if userDefaults.universityTopicName != "" {
            skipToTrackedSections()
        } else {
            setupViews()
            loadData()
        }
        
    }
    
    @IBAction func didSelectUniversity(sender: AnyObject) {
        let university = universities![selectedIndex!]
        userDefaults.universityTopicName = university.topicName
        userDefaults.season = university.resolvedSemesters.current.season
        userDefaults.year = university.resolvedSemesters.current.year.description
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func skipToTrackedSections() {
        let trackedSectionVC = self.storyboard?.instantiateViewControllerWithIdentifier("trackedSectionsVC")
        navigationController?.pushViewController(trackedSectionVC!, animated: false)
    }
    
    func loadData() {
        ViewController.startIndicator(indicator)

        datarepo.getUniversities({[weak self] universities in
            ViewController.stopIndicator((self?.indicator)!)

            if let universities = universities  {
                self?.universities = universities
                self?.pickerView?.reloadAllComponents()
                UIView.animateWithDuration(0.2, animations: {
                    self!.textField.alpha = 1
                })
            } else {
                let alert = UIAlertController(title: "No internet connection", message: "Please make sure you are connected to the internet", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
                        uiAction in self?.loadData()
                }))
                self?.presentViewController(alert, animated: true, completion: nil)
            }
            })
    }
    
    func setupViews() {
        // Hide textField while data loads
        textField.alpha = 0
        // Setup university PickerUiew
        pickerView = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 250))
        pickerView!.backgroundColor = .whiteColor()
        pickerView!.showsSelectionIndicator = true
        pickerView!.dataSource = self
        pickerView!.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = false
        toolBar.tintColor = self.primaryColor
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DefaultsViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DefaultsViewController.cancelPicker))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        textField.inputView = pickerView
        textField.inputAccessoryView = toolBar
        
        letsGoButton.enabled = false
    }
    
    func donePicker(sender: UIBarButtonItem) {
        textField.resignFirstResponder()
        selectedIndex = pickerView?.selectedRowInComponent(0)
        if 0 ..< universities!.count ~= selectedIndex! {
            letsGoButton.enabled = true
            setSelectUniversityText(universities![selectedIndex!].name)
        }
    }
    
    func cancelPicker(sender: UIBarButtonItem) {
        textField.resignFirstResponder()
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(40)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return universities?[row].name
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (universities?.count)!
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
    }
    
    func setSelectUniversityText(text: String) {
        textField.text = text
    }
}