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
            tableView.reloadData()
        }
    }
    
    var searchFlow: SearchFlow?

    override func viewDidLoad() {
        setupViews()
        loadData(true)
    }
    
    @IBAction func onRefresh(sender: AnyObject) {
        loadData(false)
    }
    
    func loadData(showLoading: Bool) {
        if showLoading {
            refreshControl?.beginRefreshing()
        }
        
        datarepo.getCourses(searchFlow?.subjectTopicName ?? "", { [weak self] courses in
            self?.refreshControl?.endRefreshing()
            if let courses = courses {
                self?.loadedCourses = courses
            } else {
                // Alert no internet
                self?.alertNoInternet({
                    self?.refreshControl?.beginRefreshing()
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
    }
    
    
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate) {
        //let selectedRow = tableView.indexPathForSelectedRow?.row
        searchFlowDelegate.searchFlow = self.searchFlow
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
        
        cell.textLabel?.text = "(\(course!.number)) \(course!.name)"
        cell.detailTextLabel?.text = "\(Common.getOpenSections(course!)) open sections of \(course!.sections.count)"
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}