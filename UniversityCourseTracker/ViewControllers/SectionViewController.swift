//
//  ViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit
import Crashlytics

class SectionViewController: UITableViewController, SearchFlowDelegate {
    var searchFlow: SearchFlow?
    let metadataCellIdentifier = "metadataCell"
    let timeCellIdentifier = "timeViewCell"
    let subscribeCellIdentifier = "subscribeCell"
    
    var lastPosition: Bool = false
    var headerContainer: UIView?
    var header: UIView?
    var switchView: UISwitch?

    // The identifier of the view controller that pushed this view
    var pusher: String?
    
    // Maintains the state of the naivagtion bar's color when going back
    var previousColor: UIColor?
    var appeared: Bool = false
    
    var subscription: Subscription?
    
    override func viewDidLoad() {
        reporting.logShowScreen(self)

        setupViews()
        subscription = searchFlow?.buildSubscription()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        // Tableview header gets fucked up in landscpare, this should set it right.
        header?.bounds = CGRect(x: 0,y: 0, width: (headerContainer?.bounds.size.width)!, height: (headerContainer?.bounds.size.height)!)
        header?.frame.origin.x = 0        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsety = scrollView.contentOffset.y
        header?.transform = CGAffineTransform(translationX: 0, y: offsety)
    }
    
    func gotoCourse(_ Sender: UIBarButtonItem) {
        let singleCourseVC = self.storyboard?.instantiateViewController(withIdentifier: AppConstants.Id.Controllers.singleCourse) as! SingleCourseViewController
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        singleCourseVC.searchFlow = searchFlow
        singleCourseVC.loadedCourse = searchFlow?.tempCourse
        self.navigationController?.show(singleCourseVC, sender: self)

    }
    
    func setupViews() {
        navigationItem.title = searchFlow!.tempCourse!.name!

        if pusher == AppConstants.Id.Controllers.trackedSections {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Course", style: .plain, target: self, action: #selector(SectionViewController.gotoCourse))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_bell_white"), style: .plain, target: self, action: #selector(popToRoot))
        }
        
        // Setup navigation bar colors depending on section status
        appeared = true
        previousColor = navigationController?.navigationBar.barTintColor
        
        // setup TableView
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.register(UINib(nibName: "TimeViewCell", bundle: Bundle.main), forCellReuseIdentifier: timeCellIdentifier)
        tableView.register(UINib(nibName: "MetadataCell", bundle: Bundle.main), forCellReuseIdentifier: metadataCellIdentifier)

        // Headerview setup
        headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 110))
        header = UIView.init(frame: headerContainer!.bounds)
        let insets = tableView.separatorInset
        header?.layoutMargins = UIEdgeInsets(top: 0, left: insets.left ,bottom: 0,right: insets.left)

        headerContainer?.addSubview(header!)

        let sectionHeader = SectionHeaderView.createView()
        sectionHeader.setSection(searchFlow!.tempSection!, semester: searchFlow!.tempSemester!)
        
        header?.addSubview(sectionHeader)
        sectionHeader.autoPinEdgesToSuperviewEdges()
        sectionHeader.sizeToFit()
        
        tableView.tableHeaderView = headerContainer
        
        setHeaderColors(false)
        
        // Setup Switch View with data from database
        switchView = UISwitch(frame:CGRect(x: 150, y: 300, width: 0, height: 0));
        switchView!.onTintColor = AppConstants.Colors.primary
        switchView!.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged);
        if coreData.getSubscription(searchFlow!.tempSection!.topicName) == nil {
            lastPosition = false
            switchView?.isOn = false
        } else {
            lastPosition = true
            switchView?.isOn = true
        }
    }

    
    func setHeaderColors(_ animate: Bool) {
        let duration = animate ? 0.2 : 0.0
        if searchFlow?.tempSection?.status == "Open" {
            self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.openSection
        } else {
            self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.closedSection
        }
        self.header?.backgroundColor = self.navigationController?.navigationBar.barTintColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setHeaderColors(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barTintColor = self.previousColor
    }
    
    // MARK: - Navigation
    
    func prepareSearchFlow(_ searchFlowDelegate: SearchFlowDelegate) {
    }
    
    // MARK: - UITableViewDelegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return searchFlow?.tempSection?.metadata.count ?? 0
        } else if section == 2 {
            return 1
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
             if let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: subscribeCellIdentifier) {
                AppConstants.Colors.configureLabel(cell.textLabel!, style: AppConstants.FontStyle.body)
                cell.accessoryView = switchView
                return cell
            }
        }
        else if (indexPath as NSIndexPath).section == 1 {
            if let cell: MetadataCell = tableView.dequeueReusableCell(withIdentifier: metadataCellIdentifier) as? MetadataCell {
                cell.isUserInteractionEnabled = false
                let modelItem = searchFlow?.tempSection?.metadata[(indexPath as NSIndexPath).row]
                cell.title.text = modelItem?.title
                
                var contentString = modelItem?.content
                contentString = contentString!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                cell.content.text = contentString
                
                return cell
            }
        } else if (indexPath as NSIndexPath).section == 2 {
            if let cell: TimeViewCell = tableView.dequeueReusableCell(withIdentifier: timeCellIdentifier) as? TimeViewCell {
                let modelItem = searchFlow?.tempSection!
                cell.isUserInteractionEnabled = false
                cell.setMeetings(modelItem!)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //selectedIndex = indexPath.row
    }
    
    func switchValueDidChange(_ sender:UISwitch!) {
        if sender.isOn == lastPosition {
            return
        }
        
        Notifications.shared?.requestNotificationPermission()
        lastPosition = !lastPosition
        
        if sender.isOn {
            coreData.addSubscription(subscription!)
        } else {
            _ = coreData.removeSubscription(subscription!.sectionTopicName)
        }
    }
}
