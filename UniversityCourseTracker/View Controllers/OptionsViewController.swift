//
//  ViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit


class OptionsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    
    var universityPickerView: UIPickerView?
    var termReuseCell: String = "termCell"
    var universityReuseCell: String = "chooseUniversityCell"
    var universityTextField: UITextField?
    
    
    var terms = Array<Semester>()
    var selectedTermIndex: Int?
    
    // Universities from the network
    var universities = Array<University>() {
        didSet {
            // Find the index of the user's univerisity in the list
            let index = universities.indexOf{$0.topicName == coreData.university!.topicName} ?? 0
    
            currentUniversity = universities[index]

            universityPickerView?.selectRow(index, inComponent: 0, animated: true)
            universityPickerView?.reloadAllComponents()
            
        }
    }
    
    // When university has been selected save it and repoplutate the terms cell
    var currentUniversity: University? {
        didSet {
            // Find university semester index
            selectedTermIndex = currentUniversity?.availableSemesters.indexOf({
                let semester = coreData.semester!
                return $0.season == semester.season && $0.year == semester.year
            })
        
            if oldValue != nil {
                // Reset selected index when user chooses a new university 
                // selectedTermIndex = 0
                
                // Save the user's selected university in the database
                coreData.university = currentUniversity!
                coreData.semester = currentUniversity!.resolvedSemesters.current
            }
            
            // Repopulate list of availableSemesters
            terms.removeAll()
            for semester in currentUniversity!.availableSemesters {
                terms.append(semester)
            }
            
            //tableView.reloadData()
            tableView.beginUpdates()
            tableView.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.reloadSections(NSIndexSet.init(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
        }
    }

    @IBAction func doneClicked(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        reporting.logShowScreen(self)

        setupViews()
        loadData()
    }
    
    func loadData() {
        appDelegate.dataRepo?.getUniversities({
            [weak self] universities in
            if let universities = universities {
                self?.universities = universities
            }
        })
    }
    
    func setupViews() {
        navigationItem.title = "Search Options"
        setupUniversityPickerView()
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
        toolBar.tintColor = AppConstants.Colors.primary
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(OptionsViewController.doneUniversityPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(OptionsViewController.cancelUniversityPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        // Fake textfield to hijack the the keyboard and replace it with a picker our view.
        universityTextField = UITextField(frame: CGRectMake(0, 0, 1, 1))
        universityTextField!.opaque = true
        view.addSubview(universityTextField!)
        universityTextField!.inputView = universityPickerView
        universityTextField!.inputAccessoryView = toolBar
    }

    func doneUniversityPicker(sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.enabled = true
        tableView.userInteractionEnabled = true

        universityTextField!.resignFirstResponder()
        let index = universityPickerView!.selectedRowInComponent(0)
        currentUniversity = universities[index]
    }

    func cancelUniversityPicker(sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.enabled = true
        tableView.userInteractionEnabled = true

        universityTextField!.resignFirstResponder()
    }
    
    // MARK: PickerView delegate
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == universityPickerView {
            return universities[row].name
        }
        return "Error"
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == universityPickerView {
            return universities.count
        }
        return 0
    }
    
    // MARK: - UITableViewDelegate Methods
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "University"
        } else if section == 1 {
            return "Term"
        }
        
        return ""
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return terms.count
        }
        return 0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    var checkedIndex: NSIndexPath?
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(universityReuseCell, forIndexPath: indexPath) as UITableViewCell
            AppConstants.Colors.configureLabel(cell.textLabel!, style: AppConstants.FontStyle.Body)

            cell.textLabel?.text = currentUniversity?.name
            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(termReuseCell, forIndexPath: indexPath) as UITableViewCell
            AppConstants.Colors.configureLabel(cell.textLabel!, style: AppConstants.FontStyle.Body)
            cell.textLabel?.text = terms[indexPath.row].readableString
            
            if indexPath.row == selectedTermIndex {
                checkedIndex = indexPath
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            // Disable modal return button
            tableView.userInteractionEnabled = false
            navigationItem.rightBarButtonItem?.enabled = false
            
            universityTextField!.becomeFirstResponder()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else if indexPath.section == 1 {
            // Unselect previous path
            if checkedIndex!.row != indexPath.row {
                let checkedCell = tableView.cellForRowAtIndexPath(checkedIndex!)
                checkedCell?.accessoryType = UITableViewCellAccessoryType.None
            }
            
            // Update selected path
            checkedIndex = indexPath
            
            // Set checked index
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            // Save currect semester
            coreData.semester = terms[indexPath.row]
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}