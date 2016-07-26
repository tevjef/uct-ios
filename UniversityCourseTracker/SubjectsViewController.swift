//
//  SubjectsViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class SubjectsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var indicator = UIActivityIndicatorView()
    var loadedSubjects: Array<Common.Subject>?
    var subjectsList: [String] = [String]()
    var selectedUniversity: Common.University?
    var selectedSemester: Common.Semester?
    var selectedSubject: Int = -1
    
    override func viewDidLoad() {
        setupViews()
        ViewController.startIndicator(indicator)
        
        getSubjects(selectedUniversity!.topicName, selectedSemester!.season, selectedSemester!.year.description, {
            subjects in
            if let subjects = subjects {
                self.loadedSubjects = subjects
                for subs in self.loadedSubjects! {
                    self.subjectsList.append(subs.name)
                }
                self.tableView.reloadData()
                ViewController.stopIndicator(self.indicator)
            } else {
                print("Error")
            }
        })
    }

    func setupViews() {
        navigationItem.title = Common.getReadableString(selectedSemester!)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        indicator = ViewController.makeActivityIndicator(self.view)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "gotoCourseList" {
            let nextViewController = segue.destinationViewController as! CoursesViewController
            let row = tableView.indexPathForSelectedRow?.row
            nextViewController.selectedSubject = loadedSubjects![row!]
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjectsList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("subjectCell", forIndexPath: indexPath) as UITableViewCell
        let subject = loadedSubjects![indexPath.row]
        
        cell.textLabel?.text = "(\(subject.number)) \(subject.name)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}