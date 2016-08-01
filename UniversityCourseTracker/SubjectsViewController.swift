//
//  SubjectsViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class SubjectsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchFlowDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var indicator = UIActivityIndicatorView()
    var loadedSubjects: Array<Common.Subject>?
    var subjectsList: [String] = [String]()
    var searchFlow: SearchFlow?
    
    override func viewDidLoad() {
    }
    
    override func viewWillAppear(animated: Bool) {
        searchFlow = SearchFlow()
        searchFlow!.universityTopicName = userDefaults.universityTopicName
        searchFlow!.season = userDefaults.season
        searchFlow!.year = userDefaults.year
        searchFlow!.tempUniversity = appConfig.university

        setupViews()
        
        loadData()
    }
    
    func loadData() {
        ViewController.startIndicator(indicator)
        datarepo.getSubjects(searchFlow!.universityTopicName!, searchFlow!.season!, searchFlow!.year!, { [weak self]
            subjects in
            if let subjects = subjects {
                self?.loadedSubjects = subjects
                for subs in (self?.loadedSubjects)! {
                    self?.subjectsList.append(subs.name)
                }
                self?.tableView.reloadData()
                ViewController.stopIndicator((self?.indicator)!)
            } else {
                ViewController.stopIndicator((self?.indicator)!)
                let alert = UIAlertController(title: "No internet connection", message: "Please make sure you are connected to the internet", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
                    uiAction in self?.loadData()
                }))
                self?.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }

    func setupViews() {
        let titleView = self.makeTitleViewWithSubtitle(userDefaults.season.capitalizedString + " " + userDefaults.year, subtitle: (appConfig.university?.abbr)!)
        navigationItem.titleView = titleView
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        indicator = ViewController.makeActivityIndicator(self.view)
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
        let subject = loadedSubjects![selectedRow!]
        searchFlow?.tempSubject = subject
        searchFlow?.subjectTopicName = subject.topicName
        searchFlowDelegate.searchFlow = self.searchFlow
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