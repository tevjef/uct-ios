//
//  TrackedSectionsViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/8/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class TrackedSectionViewController: UITableViewController {

    let sectionCellIdentifier = "sectionCell"

    var dataSet: Array<Subscription>?
    var selectedIndex: NSIndexPath?

    var sectionedDataSet = OrderedDictionary<String, Array<Subscription>>()
    
    @IBAction func refresh(sender: UIRefreshControl) {
        hideRefreshing()
    }
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        setupViews()
        
        tableView.registerNib(UINib(nibName: "SectionViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: sectionCellIdentifier)
        tableView.sectionHeaderHeight = 0.0;
        tableView.sectionFooterHeight = 0.0;
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45
        
        loadData()
        
    }
    
    func loadData() {

        
        dataSet = coreData.getAllSubscriptions()
        for subs in dataSet! {
            Timber.i("Subscription=" + subs.sectionTopicName)
        }
        
        dataSet?.sortInPlace({
            let subjectLHS = $0.getSubject()
            let courseLHS = $0.getCourse()
            let sectionLHS = $0.getSection()
            
            let subjectRHS = $1.getSubject()
            let courseRHS = $1.getCourse()
            let sectionRHS = $1.getSection()
            
            return "\(subjectLHS.name)\(courseLHS.number)\(sectionLHS.number)" <  "\(subjectRHS.name)\(courseRHS.number)\(sectionRHS.number)"
        })
        
        sectionedDataSet.removeAll()
        for data in dataSet! {
            let courseName = data.getCourse().name
            if sectionedDataSet[courseName] != nil {
                sectionedDataSet[courseName]!.append(data)
            } else {
                sectionedDataSet[courseName] = Array<Subscription>()
                sectionedDataSet[courseName]!.append(data)
            }
        }
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Section View Controller may reset the color
        self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.primary
        
        delay(2.0, closure: {
            self.loadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        navigationItem.title = "Tracked Sections"

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
    }
    
    // MARK: - UITableViewDelegate Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getValueAtIndex(section).count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionedDataSet.orderedKeys.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getKeyAtIndex(section)
    }

    func getKeyAtIndex(index: Int) -> String {
            return sectionedDataSet.orderedKeys[index]
    }
    
    func getValueAtIndex(section: Int) -> Array<Subscription> {
        return sectionedDataSet[getKeyAtIndex(section)]!
    }
    
    func getSubscriptionInValue(indexPath: NSIndexPath) -> Subscription {
        return getValueAtIndex(indexPath.section)[indexPath.row]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            if let cell: SectionViewCell = tableView.dequeueReusableCellWithIdentifier(sectionCellIdentifier) as? SectionViewCell {
                let modelItem = getSubscriptionInValue(indexPath).getSection()
                cell.setSection(modelItem)
                return cell
            }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        gotoSection()
    }
    
    func gotoSection() {
        let sectionVC = self.storyboard?.instantiateViewControllerWithIdentifier(AppConstants.Id.Controllers.section) as! SectionViewController
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        sectionVC.pusher = AppConstants.Id.Controllers.trackedSections
        prepareSearchFlow(sectionVC)
        self.navigationController?.showViewController(sectionVC, sender: self)
        
    }
    
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate) {
        searchFlowDelegate.searchFlow = getSubscriptionInValue(selectedIndex!).getSearchFlow()
    }
}