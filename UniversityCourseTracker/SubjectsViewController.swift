//
//  SubjectsViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class SubjectsViewController: UITableViewController, SearchFlowDelegate {

    var loadedSubjects: Array<Common.Subject>? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchFlow: SearchFlow?
    
    @IBAction func onRefresh(sender: UIRefreshControl) {
        loadData(false)
    }
    
    override func viewDidLoad() {
      searchFlow = SearchFlow()
        searchFlow!.universityTopicName = userDefaults.universityTopicName
        searchFlow!.season = userDefaults.season
        searchFlow!.year = userDefaults.year
        searchFlow!.tempUniversity = appConfig.university
        
        setupViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadData(true)
    }
    
    func loadData(showLoading: Bool) {
        if showLoading {
            refreshControl?.beginRefreshing()
        }
        
        datarepo.getSubjects(searchFlow!.universityTopicName!, searchFlow!.season!, searchFlow!.year!, { [weak self]
            subjects in
            self?.refreshControl?.endRefreshing()
            if let subjects = subjects {
                self?.loadedSubjects = subjects
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
        let semester = userDefaults.season.capitalizedString + " " + userDefaults.year
        let uni = (appConfig.university?.abbr) ?? ""
        
        //let titleView = self.makeTitleViewWithSubtitle(semester, subtitle: uni)
        //navigationItem.titleView = titleView
        navigationItem.title = uni +  " " + semester
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "gotoCourseList" {
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
        
        cell.textLabel?.text = "(\(subject?.number ?? "")) \(subject?.name ?? "")"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}