//
//  SubjectsViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class CoursesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchFlowDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var indicator = UIActivityIndicatorView()
    var loadedCourses: Array<Common.Course>?
    var courseList: [String] = [String]()
    var searchFlow: SearchFlow?
    var selectedCourse: Int = -1

    override func viewDidLoad() {
        setupViews()
        ViewController.startIndicator(indicator)
        loadData()
    }

    func loadData() {
        datarepo.getCourses(searchFlow!.subjectTopicName!, { [weak self] courses in
            if let courses = courses {
                self?.loadedCourses = courses
                for course in (self?.loadedCourses!)! {
                    self?.courseList.append(course.name)
                }
                self?.tableView.reloadData()
                ViewController.stopIndicator((self?.indicator)!)
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
        navigationItem.title = searchFlow?.tempSubject?.name
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        indicator = ViewController.makeActivityIndicator(self.view)
    }

    // MARK: - UITableViewDelegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseList.count
    }
    
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate) {
        //let selectedRow = tableView.indexPathForSelectedRow?.row
        searchFlowDelegate.searchFlow = self.searchFlow
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("courseCell", forIndexPath: indexPath) as UITableViewCell

        let course = loadedCourses![indexPath.row]
        cell.textLabel?.text = "(\(course.number)) \(course.name)"
        cell.detailTextLabel?.text = "\(Common.getOpenSections(course)) open sections of \(course.sections.count)"
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}