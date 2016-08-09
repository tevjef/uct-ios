//
//  SubjectsViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class CoursesViewController: UITableViewController, SearchFlowDelegate {
    
    var loadedCourses: Array<Common.Course>? {
        didSet {
            if loadedCourses?.count == oldValue?.count {
                return
            }
                
            UIView.transitionWithView(tableView, duration: 0.35, options: .TransitionCrossDissolve, animations: {
                () -> Void in
                self.tableView.reloadData()
            }, completion: nil);
        }
    }
    
    var searchFlow: SearchFlow?
    
    override func viewDidLoad() {
        setupViews()
        loadData(true)
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        loadData(false)
    }
    
    func loadData(showLoading: Bool) {
        if showLoading {
            showRefreshing({self.loadedCourses?.count == 0})
        }
        
        datarepo.getCourses(searchFlow?.subjectTopicName ?? "", { [weak self]
            courses in
            self?.hideRefreshing()
            if let courses = courses {
                self?.loadedCourses = courses
            } else {
                // Alert no internet
                self?.alertNoInternet({
                    self?.showRefreshing()
                    // Wait n seconds then retry loading, if user hasn't navigated away
                    self?.delay(5, closure: {
                        self?.loadData(true)
                    })
                })
            }
        })
    }
    
    func setupViews() {
        navigationItem.title = searchFlow?.tempSubject?.name
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_bell_white"), style: .Plain, target: self, action: #selector(popToRoot))
    }
    
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate) {
        let course = loadedCourses![tableView.indexPathForSelectedRow!.row]
        searchFlow?.courseTopicName = course.topicName
        searchFlow?.tempCourse = course
        searchFlowDelegate.searchFlow = self.searchFlow
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == AppConstants.Id.Segue.sections {
            let nextViewController = segue.destinationViewController as! SingleCourseViewController
            nextViewController.loadedCourse = loadedCourses![(tableView.indexPathForSelectedRow?.row)!]
            prepareSearchFlow(nextViewController)
        }
    }

    // MARK: - UITableViewDelegate Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedCourses?.count ?? 0
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("courseCell", forIndexPath: indexPath) as UITableViewCell

        let course = loadedCourses?[indexPath.row]
        
        if course == nil {
            return cell
        }
        
        cell.textLabel?.text = "\(course!.number): \(course!.name)"
        cell.detailTextLabel?.text = "\(Common.getOpenSections(course!)) open sections of \(course!.sections.count)"
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}