//
//  SubjectsViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class SubjectsViewController: UITableViewController, SearchFlowDelegate {

    var loadedSubjects: Array<Subject>? {
        didSet {
            if loadedSubjects?.count == oldValue?.count {
                return
            }
            
            UIView.transitionWithView(tableView, duration: 0.35, options: .TransitionCrossDissolve, animations: {
                () -> Void in
                    self.tableView.reloadData()
            }, completion: nil);
        }
    }
    
    var searchFlow: SearchFlow?

    override func viewWillAppear(animated: Bool) {
        searchFlow = SearchFlow()
        refreshSearchFlow()
        setupViews()
        loadData(true)
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        loadData(false)
    }
    
    func loadData(showLoading: Bool) {
        if showLoading {
            showRefreshing({self.loadedSubjects?.count == 0})
        }
        refreshSearchFlow()
        
        datarepo.getSubjects(searchFlow!.universityTopicName!, searchFlow!.season!, searchFlow!.year!, { [weak self]
            subjects in
            self?.hideRefreshing()
            if let subjects = subjects {
                self?.loadedSubjects = subjects
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
        let semesterString = coreData.semester!.readableString
        let uni = coreData.university?.abbr ?? "Err"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        //let titleView = self.makeTitleViewWithSubtitle(semester, subtitle: uni)
        //navigationItem.titleView = titleView
        navigationItem.title = uni +  " " + semesterString
    }
    
    func refreshSearchFlow() {
        searchFlow!.universityTopicName = coreData.university?.topicName
        searchFlow!.season = coreData.semester?.season
        searchFlow!.year = coreData.semester?.year.description
        searchFlow!.tempSemester = coreData.semester!
        searchFlow!.tempUniversity = coreData.university
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == AppConstants.Id.Segue.courses {
            let nextViewController = segue.destinationViewController as! CoursesViewController
            prepareSearchFlow(nextViewController)
        }
    }
    
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate) {
        let selectedRow = tableView.indexPathForSelectedRow?.row
        let subject = loadedSubjects?[selectedRow!]
        searchFlow?.tempSubject = subject
        searchFlow?.subjectTopicName = subject?.topicName
        searchFlowDelegate.searchFlow = self.searchFlow
    }
    
    // MARK: - UITableViewDelegate Methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedSubjects?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("subjectCell", forIndexPath: indexPath) as UITableViewCell
        let subject = loadedSubjects?[indexPath.row]
        
        cell.textLabel?.text = "\(subject?.number ?? ""): \(subject?.name ?? "")"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}