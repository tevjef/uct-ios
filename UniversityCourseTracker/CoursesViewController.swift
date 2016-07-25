//
//  SubjectsViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class CoursesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var indicator = UIActivityIndicatorView()
    var loadedCourses: Array<Common.Course>?
    var courseList: [String] = [String]()
    var subjectTopic: String?
    var selectedCourse: Int = -1
    
    override func viewDidLoad() {
        activityIndicator()
        startIndicator()
        
        getCourses(subjectTopic!, courses: { (courses: Array<Common.Course>?) in
            if let courses = courses {
                self.loadedCourses = courses
                for course in self.loadedCourses! {
                    self.courseList.append(course.name)
                }
                self.tableView.reloadData()
                self.stopIndicator()
            } else {
                print("Error")
            }
        })
    }
    
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
    
    // MARK: - UITableViewDelegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("courseCell", forIndexPath: indexPath) as UITableViewCell
        
        let course = loadedCourses![indexPath.row]
        cell.textLabel?.text = course.name
        cell.detailTextLabel?.text = "\(Common.getOpenSections(course)) open sections of \(loadedCourses!.count)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}