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
        header?.bounds = CGRectMake(0,0, (headerContainer?.bounds.size.width)!, (headerContainer?.bounds.size.height)!)
        header?.frame.origin.x = 0        
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsety = scrollView.contentOffset.y
        header?.transform = CGAffineTransformMakeTranslation(0, offsety)
    }
    
    func gotoCourse(Sender: UIBarButtonItem) {
        let singleCourseVC = self.storyboard?.instantiateViewControllerWithIdentifier(AppConstants.Id.Controllers.singleCourse) as! SingleCourseViewController
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        singleCourseVC.searchFlow = searchFlow
        singleCourseVC.loadedCourse = searchFlow?.tempCourse
        self.navigationController?.showViewController(singleCourseVC, sender: self)

    }
    
    func setupViews() {
        navigationItem.title = searchFlow!.tempCourse!.name

        if pusher == AppConstants.Id.Controllers.trackedSections {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Course", style: .Plain, target: self, action: #selector(SectionViewController.gotoCourse))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_bell_white"), style: .Plain, target: self, action: #selector(popToRoot))
        }
        
        // Setup navigation bar colors depending on section status
        appeared = true
        previousColor = navigationController?.navigationBar.barTintColor
        
        // setup TableView
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.registerNib(UINib(nibName: "TimeViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: timeCellIdentifier)
        tableView.registerNib(UINib(nibName: "MetadataCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: metadataCellIdentifier)

        // Headerview setup
        headerContainer = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 110))
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
        
        setHeaderColors(true)
        
        // Setup Switch View with data from database
        switchView = UISwitch(frame:CGRectMake(150, 300, 0, 0));
        switchView!.onTintColor = AppConstants.Colors.primary
        switchView!.addTarget(self, action: #selector(switchValueDidChange), forControlEvents: .ValueChanged);
        if coreData.getSubscription(searchFlow!.tempSection!.topicName) == nil {
            lastPosition = false
            switchView?.on = false
        } else {
            lastPosition = true
            switchView?.on = true
        }
    }

    
    func setHeaderColors(animate: Bool) {
        let duration = animate ? 0.2 : 0.0
        if searchFlow?.tempSection?.status == "Open" {
            UIView.animateWithDuration(duration, animations: {
                self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.openSection
            })
        } else {
            UIView.animateWithDuration(duration, animations: {
                self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.closedSection
            })
        }
        UIView.animateWithDuration(duration, animations: {
            self.header?.backgroundColor = self.navigationController?.navigationBar.barTintColor
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        if appeared {
            setHeaderColors(true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animateWithDuration(0.2, animations: {
            self.navigationController?.navigationBar.barTintColor = self.previousColor
        })
        
        UIView.animateWithDuration(0.2, animations: {
            self.header?.backgroundColor = self.previousColor
        })

    }
    
    // MARK: - Navigation
    
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate) {
    }
    
    // MARK: - UITableViewDelegate Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return searchFlow?.tempSection?.metadata.count ?? 0
        } else if section == 2 {
            return 1
        }
        return 0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
             if let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(subscribeCellIdentifier) {
                AppConstants.Colors.configureLabel(cell.textLabel!, style: AppConstants.FontStyle.Body)
                cell.accessoryView = switchView
                return cell
            }
        }
        else if indexPath.section == 1 {
            if let cell: MetadataCell = tableView.dequeueReusableCellWithIdentifier(metadataCellIdentifier) as? MetadataCell {
                cell.userInteractionEnabled = false
                let modelItem = searchFlow?.tempSection?.metadata[indexPath.row]
                cell.title.text = modelItem?.title
                
                var contentString = modelItem?.content
                contentString = contentString!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                cell.content.text = contentString
                
                return cell
            }
        } else if indexPath.section == 2 {
            if let cell: TimeViewCell = tableView.dequeueReusableCellWithIdentifier(timeCellIdentifier) as? TimeViewCell {
                let modelItem = searchFlow?.tempSection!
                cell.userInteractionEnabled = false
                cell.setMeetings(modelItem!)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //selectedIndex = indexPath.row
    }
    
    func switchValueDidChange(sender:UISwitch!) {
        if sender.on == lastPosition {
            return
        }
        
        Notifications.requestNotificationPermission()
        lastPosition = !lastPosition
        
        if sender.on {
            coreData.addSubscription(subscription!)
        } else {
            coreData.removeSubscription(subscription!.sectionTopicName)
        }
    }
}