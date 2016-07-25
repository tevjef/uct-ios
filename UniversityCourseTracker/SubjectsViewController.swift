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
    var year: String?
    var season: String?
    var universityTopic: String?
    var selectedSubject: Int = -1
    
    override func viewDidLoad() {
        activityIndicator()
        startIndicator()
        
        getSubjects(universityTopic!, season: season!, year: year!, subjects: { (subjects: Array<Common.Subject>?) in
            if let subjects = subjects {
                self.loadedSubjects = subjects
                for subs in self.loadedSubjects! {
                    self.subjectsList.append(subs.name)
                }
                self.tableView.reloadData()
                self.stopIndicator()
            } else {
                print("Error")
            }
        })
    }
    
    // MARK: - UI Shit
    func startIndicator() {
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.whiteColor()
    }
    
    func stopIndicator() {
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "gotoCourseList" {
            let nextViewController = segue.destinationViewController as! CoursesViewController
            let row = tableView.indexPathForSelectedRow?.row
            nextViewController.subjectTopic = loadedSubjects![row!].topicName
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjectsList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("subjectCell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = subjectsList[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}