//
//  ViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class SectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchFlowDelegate {
    var searchFlow: SearchFlow?

    override func viewDidLoad() {
        setupViews()
        // Do any additional setup after loading the view, typically from a nib.
    
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = CGPointZero;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var previousColor: UIColor?
    
    func setupViews() {
        previousColor = navigationController?.navigationBar.barTintColor
        if searchFlow?.tempSection?.status == "Open" {
            self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.openSection
        } else {
            self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.closedSection
        }

        //let subject = searchFlow?.tempSubject
        //let titleView = self.makeTitleViewWithSubtitle(searchFlow!.tempCourse!.name, subtitle: "\(subject!.season.capitalizedString) \(subject!.year)")
        
        navigationItem.title = searchFlow!.tempCourse!.name
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = previousColor
    }
    
    // MARK: - Navigation
    
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate) {
        searchFlow?.buildSubscription()
    }
    
    // MARK: - UITableViewDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("subjectCell", forIndexPath: indexPath) as UITableViewCell
        //let subject = loadedSubjects?[indexPath.row]
        
        //cell.textLabel?.text = "\(subject?.number ?? ""): \(subject?.name ?? "")"
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}