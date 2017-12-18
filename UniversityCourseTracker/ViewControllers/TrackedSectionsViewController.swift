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
    var selectedIndex: IndexPath?

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

        self.dataSet?.sort(by: {
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
            if self.sectionedDataSet[courseName!] != nil {
                self.sectionedDataSet[courseName!]!.append(data)
            } else {
                self.sectionedDataSet[courseName!] = Array<Subscription>()
                self.sectionedDataSet[courseName!]!.append(data)
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

    override func viewWillAppear(_ animated: Bool) {
        // Section View Controller may reset the color
        self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.primary
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupViews() {
        navigationItem.title = "Tracked Sections"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true

        tableView.register(UINib(nibName: "SectionViewCell", bundle: Bundle.main), forCellReuseIdentifier: sectionCellIdentifier)
        //tableView.sectionHeaderHeight = 0.0;
        tableView.sectionFooterHeight = 0.0;
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45

    }

    // MARK: - UITableViewDelegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getValueAtIndex(section).count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionedDataSet.orderedKeys.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = PaddedLabel()
        headerLabel.padding = UIEdgeInsets(top: 5, left: tableView.separatorInset.left, bottom: -5, right: tableView.separatorInset.right)
        headerLabel.text = getKeyAtIndex(section).uppercased()
        headerLabel.font = UIFont.boldSystemFont(ofSize: 12)
        headerLabel.textColor = AppConstants.Colors.primaryDarkText
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = .byWordWrapping
        headerLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        headerLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        headerLabel.sizeToFit()
        headerLabel.preservesSuperviewLayoutMargins = true
        //pickerLabel.adjustsFontSizeToFitWidth = true

        //print("\(tableView.cell)")
        return headerLabel
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 38
        }

        return UITableViewAutomaticDimension;
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getKeyAtIndex(section)
    }

    func getKeyAtIndex(_ index: Int) -> String {
        if sectionedDataSet.orderedKeys.count < index {
            return ""
        }
        return sectionedDataSet.orderedKeys[index]
    }

    func getValueAtIndex(_ section: Int) -> Array<Subscription> {
        return sectionedDataSet[getKeyAtIndex(section)]!
    }

    func getSubscriptionInValue(_ indexPath: IndexPath) -> Subscription {
        return getValueAtIndex((indexPath as NSIndexPath).section)[(indexPath as NSIndexPath).row]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if let cell: SectionViewCell = tableView.dequeueReusableCell(withIdentifier: sectionCellIdentifier) as? SectionViewCell {
                let modelItem = getSubscriptionInValue(indexPath).getSection()
                cell.setSection(modelItem)
                return cell
            }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        tableView.deselectRow(at: indexPath, animated: true)

        gotoSection()
    }

    func gotoSection() {
        let sectionVC = self.storyboard?.instantiateViewController(withIdentifier: AppConstants.Id.Controllers.section) as! SectionViewController
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        sectionVC.pusher = AppConstants.Id.Controllers.trackedSections
        prepareSearchFlow(sectionVC)
        self.navigationController?.show(sectionVC, sender: self)

    }

    func prepareSearchFlow(_ searchFlowDelegate: SearchFlowDelegate) {
        searchFlowDelegate.searchFlow = getSubscriptionInValue(selectedIndex!).getSearchFlow()
    }

    func onSubscriptionAdded(_ sender: AnyObject) {
        loadData()
    }

    func onSubscriptionRemoved(_ sender: AnyObject) {
        loadData()
    }

    func onSubscriptionsUpdated(_ sender: AnyObject) {
        loadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self,
                selector: #selector(onSubscriptionAdded),
                name: NSNotification.Name(rawValue: CoreDataManager.addSubscriptionNotification),
                object: nil
        )
        NotificationCenter.default.addObserver(self,
                selector: #selector(onSubscriptionRemoved),
                name: NSNotification.Name(rawValue: CoreDataManager.removeSubscriptionNotification),
                object: nil
        )
        NotificationCenter.default.addObserver(self,
                selector: #selector(onSubscriptionsUpdated),
                name: NSNotification.Name(rawValue: CoreDataManager.updateSubscriptionsNotification),
                object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self,
                name: NSNotification.Name(rawValue: CoreDataManager.addSubscriptionNotification),
                object: nil
        )
        NotificationCenter.default.removeObserver(self,
                name: NSNotification.Name(rawValue: CoreDataManager.removeSubscriptionNotification),
                object: nil
        )
        NotificationCenter.default.removeObserver(self,
                name: NSNotification.Name(rawValue: CoreDataManager.updateSubscriptionsNotification),
                object: nil
        )
    }
}
