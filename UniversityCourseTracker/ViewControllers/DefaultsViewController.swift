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
    @IBOutlet weak var contentView: UIView!

    var indicator: UIActivityIndicatorView?
    var pickerView: UIPickerView?
    var universities: Array<University>?
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        // Skip vc if user has selected a default university
        self.letsGoButton.alpha = 0
        navigationController?.navigationBar.isHidden = true
        if coreData.university != nil {
            skipToTrackedSections()
        } else {
            reporting.logShowScreen(self)
            setupViews()
            loadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func skipToTrackedSections() {
        let trackedSectionVC = self.storyboard?.instantiateViewController(withIdentifier: AppConstants.Id.Controllers.trackedSections)
        navigationController?.pushViewController(trackedSectionVC!, animated: false)
    }

    func loadData() {
        startIndicator(indicator, {self.universities == nil})

        datarepo.getUniversities({[weak self] universities in
            self?.stopIndicator(self?.indicator)

            if let universities = universities  {
                self?.universities = universities
                self?.pickerView?.reloadAllComponents()
                UIView.animate(withDuration: 0.2, animations: {
                    self!.textField.alpha = 1
                })
            } else {
                // Alert no internet
                self?.alertNoInternet({
                    self?.startIndicator(self?.indicator)
                    // Wait n seconds then retry loading, if user hasn't navigated away
                    self?.delay(5, closure: {
                        self?.loadData()
                    })
                })
            }
        })
    }
    
    func setupViews() {
        indicator = makeActivityIndicator(self.view)
        
        contentView.backgroundColor = AppConstants.Colors.primaryLight
        letsGoButton.backgroundColor = AppConstants.Colors.primary
        textField.layer.cornerRadius = 5
        textField.tintColor = UIColor.clear
        
        // Hide textField while data loads
        textField.alpha = 0
        textField.textColor = AppConstants.Colors.primaryDarkText
        // Setup university PickerUiew
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 200))
        pickerView!.backgroundColor = UIColor.white
        pickerView!.showsSelectionIndicator = true
        pickerView!.dataSource = self
        pickerView!.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        toolBar.tintColor = AppConstants.Colors.primary
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DefaultsViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DefaultsViewController.cancelPicker))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textField.inputView = pickerView
        textField.inputAccessoryView = toolBar
        
        letsGoButton.isEnabled = false
    }
    
    
    @IBAction func didSelectUniversity(_ sender: AnyObject) {
        let university = universities![selectedIndex!]
        coreData.university = university
        coreData.semester = university.resolvedSemesters.current
        
        reporting.logDefaultUniversity(university.topicId)
    }
    
    func donePicker(_ sender: UIBarButtonItem) {
        textField.resignFirstResponder()
        selectedIndex = pickerView?.selectedRow(inComponent: 0)
        if 0 ..< universities!.count ~= selectedIndex! {
            letsGoButton.isEnabled = true
            setSelectUniversityText(universities![selectedIndex!].name)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.letsGoButton.alpha = 1
        })
    }
    
    func cancelPicker(_ sender: UIBarButtonItem) {
        textField.resignFirstResponder()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        AppConstants.Colors.configureLabel(pickerLabel, style: .headline)
        pickerLabel.text = universities?[row].name
        pickerLabel.font = UIFont.systemFont(ofSize: 20)
        pickerLabel.adjustsFontSizeToFitWidth = true
        pickerLabel.textAlignment = .center
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(40)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (universities?.count)!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
    }
    
    func setSelectUniversityText(_ text: String) {
        textField.text = text
    }
}
