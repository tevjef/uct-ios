//
//  TrackedSectionsViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/8/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit
import PureLayout
import CocoaLumberjack

class TrackedSectionViewController: UITableViewController {

    let sectionCellIdentifier = "sectionCell"

    var dataSet: Array<Subscription>?
    var selectedIndex: NSIndexPath?

    var sectionedDataSet = OrderedDictionary<String, Array<Subscription>>()
    
    override func viewDidLoad() {
        reporting.logShowScreen(self)

      
        setupViews()

        coreData.refreshAllSubscriptions()
        loadData()
    }
    
    func loadData() {
        DDLogInfo("loadData()")

        self.dataSet = self.coreData.getAllSubscriptions()
        
        for subs in self.dataSet! {
            DDLogInfo("Subscription=" + subs.sectionTopicName)
        }
        
        self.dataSet?.sortInPlace({
            let subjectLHS = $0.getSubject()
            let courseLHS = $0.getCourse()
            let sectionLHS = $0.getSection()
            
            let subjectRHS = $1.getSubject()
            let courseRHS = $1.getCourse()
            let sectionRHS = $1.getSection()
            
            return "\(subjectLHS.name)\(courseLHS.number)\(sectionLHS.number)" <  "\(subjectRHS.name)\(courseRHS.number)\(sectionRHS.number)"
        })
        
        self.sectionedDataSet.removeAll()
        for data in self.dataSet! {
            let courseName = data.getCourse().name
            if self.sectionedDataSet[courseName] != nil {
                self.sectionedDataSet[courseName]!.append(data)
            } else {
                self.sectionedDataSet[courseName] = Array<Subscription>()
                self.sectionedDataSet[courseName]!.append(data)
            }
        }

        if self.sectionedDataSet.count == 0 {
            showEmptyScreen()
        } else {
            self.tableView.backgroundView = UIView()
        }

        self.tableView.reloadData()
    }

    func showEmptyScreen() {
        let noSectionView = NoSections.createView()
        tableView.backgroundView = noSectionView
    }
    
    override func viewWillAppear(animated: Bool) {
        // Section View Controller may reset the color
        self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.primary
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        navigationItem.title = "Tracked Sections"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
        navigationController?.navigationBar.hidden = false
        self.navigationItem.hidesBackButton = true
        
        tableView.registerNib(UINib(nibName: "SectionViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: sectionCellIdentifier)
        //tableView.sectionHeaderHeight = 0.0;
        tableView.sectionFooterHeight = 0.0;
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45

    }
    
    // MARK: - UITableViewDelegate Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getValueAtIndex(section).count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionedDataSet.orderedKeys.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = PaddedLabel()
        headerLabel.padding = UIEdgeInsets(top: 5, left: tableView.separatorInset.left, bottom: -5, right: tableView.separatorInset.right)
        headerLabel.text = getKeyAtIndex(section).uppercaseString
        headerLabel.font = UIFont.boldSystemFontOfSize(12)
        headerLabel.textColor = AppConstants.Colors.primaryDarkText
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = .ByWordWrapping
        headerLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        headerLabel.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Vertical)
        headerLabel.sizeToFit()
        headerLabel.preservesSuperviewLayoutMargins = true
        //pickerLabel.adjustsFontSizeToFitWidth = true
        
        //print("\(tableView.cell)")
        return headerLabel
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 38
        }
        
        return UITableViewAutomaticDimension;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getKeyAtIndex(section)
    }

    func getKeyAtIndex(index: Int) -> String {
        if sectionedDataSet.orderedKeys.count < index {
            return ""
        }
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
    
    func onSubscriptionAdded(sender: AnyObject) {
        loadData()
    }
    
    func onSubscriptionRemoved(sender: AnyObject) {
        loadData()
    }
    
    func onSubscriptionsUpdated(sender: AnyObject) {
        loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onSubscriptionAdded), name: CoreDataManager.addSubscriptionNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onSubscriptionRemoved), name: CoreDataManager.removeSubscriptionNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onSubscriptionsUpdated), name: CoreDataManager.updateSubscriptionsNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CoreDataManager.addSubscriptionNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CoreDataManager.removeSubscriptionNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CoreDataManager.updateSubscriptionsNotification, object: nil)
    }
}