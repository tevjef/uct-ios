//
//  ViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit


class OptionsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    
    var activityIdicator: UIActivityIndicatorView?
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
            let index = universities.index{$0.topicName == coreData.university!.topicName} ?? 0
    
            currentUniversity = universities[index]

            universityTextField?.isUserInteractionEnabled = true
            universityPickerView?.selectRow(index, inComponent: 0, animated: true)
            universityPickerView?.reloadAllComponents()
            stopIndicator(activityIdicator)
        }
    }
    
    // When university has been selected save it and repoplutate the terms cell
    var currentUniversity: University? {
        didSet {
            // Find university semester index
            selectedTermIndex = currentUniversity?.availableSemesters.index(where: {
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
            
            UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
                }, completion: nil)
        }
    }

    @IBAction func doneClicked(_ sender: AnyObject) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        reporting.logShowScreen(self)

        setupViews()
        loadData()
    }
    
    func loadData() {
        startIndicator(activityIdicator, {self.universities.count == 0})

        appDelegate.dataRepo?.getUniversities({
            [weak self] universities in
            if let universities = universities {
                self?.universities = universities
            }
        })
    }
    
    func setupViews() {
        navigationItem.title = "Search Options"
        activityIdicator = makeActivityIndicator(self.view)
        setupUniversityPickerView()
    }
    
    func setupUniversityPickerView() {
        universityPickerView = UIPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 200))
        universityPickerView!.backgroundColor = UIColor.white
        universityPickerView!.showsSelectionIndicator = true
        universityPickerView!.dataSource = self
        universityPickerView!.delegate = self
        universityPickerView!.translatesAutoresizingMaskIntoConstraints = false
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        toolBar.tintColor = AppConstants.Colors.primary
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(OptionsViewController.doneUniversityPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(OptionsViewController.cancelUniversityPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        // Fake textfield to hijack the the keyboard and replace it with a picker our view.
        universityTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        universityTextField!.isOpaque = true
        view.addSubview(universityTextField!)
        universityTextField!.inputView = universityPickerView
        universityTextField!.inputAccessoryView = toolBar
        universityTextField!.isUserInteractionEnabled = false

    }

    func doneUniversityPicker(_ sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        tableView.isUserInteractionEnabled = true

        universityTextField!.resignFirstResponder()
        let index = universityPickerView!.selectedRow(inComponent: 0)
        currentUniversity = universities[index]
    }

    func cancelUniversityPicker(_ sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        tableView.isUserInteractionEnabled = true

        universityTextField!.resignFirstResponder()
    }
    
    // MARK: PickerView delegate
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        AppConstants.Colors.configureLabel(pickerLabel, style: .headline)
        pickerLabel.text = universities[row].name
        pickerLabel.font = UIFont.systemFont(ofSize: 20)
        pickerLabel.adjustsFontSizeToFitWidth = true
        pickerLabel.textAlignment = .center
        
        return pickerLabel
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == universityPickerView {
            return universities.count
        }
        return 0
    }
    
    // MARK: - UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String = ""
        if section == 0 {
            title = "University"
        } else if section == 1 {
            title = "Term"
        }

        let headerLabel = PaddedLabel()
        headerLabel.padding = UIEdgeInsets(top: 5, left: tableView.separatorInset.left,bottom: -5 ,right: tableView.separatorInset.left)
        headerLabel.text = title.uppercased()
        headerLabel.font = UIFont.boldSystemFont(ofSize: 12)
        headerLabel.textColor = AppConstants.Colors.primaryDarkText
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = .byWordWrapping
        headerLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        headerLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        headerLabel.sizeToFit()
        //pickerLabel.adjustsFontSizeToFitWidth = true
        
        return headerLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && currentUniversity != nil {
            return 1
        } else if section == 1 {
            return terms.count
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if currentUniversity != nil {
            return 2
        }
        
        return 0
    }
    
    var checkedIndex: IndexPath?
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: universityReuseCell, for: indexPath) as UITableViewCell
            cell.selectedBackgroundView = AppConstants.Colors.primaryLight.viewFromColor()
            AppConstants.Colors.configureLabel(cell.textLabel!, style: AppConstants.FontStyle.body)

            let title = currentUniversity?.name
            if title != nil {
                cell.isUserInteractionEnabled = true
                cell.textLabel?.text = currentUniversity?.name
            }
            return cell
        }
        
        if (indexPath as NSIndexPath).section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: termReuseCell, for: indexPath) as UITableViewCell
            cell.selectedBackgroundView = AppConstants.Colors.primaryLight.viewFromColor()
            AppConstants.Colors.configureLabel(cell.textLabel!, style: AppConstants.FontStyle.body)
            cell.tintColor = AppConstants.Colors.primary
            
            cell.textLabel?.text = terms[(indexPath as NSIndexPath).row].readableString
            
            if (indexPath as NSIndexPath).row == selectedTermIndex {
                checkedIndex = indexPath
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            // Disable modal return button
            tableView.isUserInteractionEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
            
            universityTextField!.becomeFirstResponder()
            tableView.deselectRow(at: indexPath, animated: true)
        } else if (indexPath as NSIndexPath).section == 1 {
            // Unselect previous path
            if (checkedIndex! as NSIndexPath).row != (indexPath as NSIndexPath).row {
                let checkedCell = tableView.cellForRow(at: checkedIndex!)
                checkedCell?.accessoryType = UITableViewCellAccessoryType.none
            }
            
            // Update selected path
            checkedIndex = indexPath
            
            // Set checked index
            let cell = tableView.cellForRow(at: indexPath)!
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            
            // Save currect semester
            coreData.semester = terms[(indexPath as NSIndexPath).row]
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
