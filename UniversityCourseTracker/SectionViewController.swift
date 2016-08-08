//
//  ViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class SectionViewController: UITableViewController, SearchFlowDelegate {
    var searchFlow: SearchFlow?
    let metadataCellIdentifier = "metadataCell"
    let timeCellIdentifier = "timeViewCell"
    let subscribeCellIdentifier = "subscribeCell"

    
    // Maintains the state of the naivagtion bar's color when going back
    var previousColor: UIColor?
    var appeared: Bool = false
    
    override func viewDidLoad() {
        setupViews()
        // Do any additional setup after loading the view, typically from a nib.
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //func scrollViewDidScroll(scrollView: UIScrollView) {
    //    if scrollView.contentOffset.y <= 0 {
     //       scrollView.contentOffset = CGPointZero;
     //   }
    //}

    


    func setupViews() {
        appeared = true
        previousColor = navigationController?.navigationBar.barTintColor

        if searchFlow?.tempSection?.status == "Open" {
            self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.openSection
        } else {
            self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.closedSection
        }

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        tableView.registerNib(UINib(nibName: "TimeViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: timeCellIdentifier)
        tableView.registerNib(UINib(nibName: "MetadataCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: metadataCellIdentifier)

    
        //let subject = searchFlow?.tempSubject
        //let titleView = self.makeTitleViewWithSubtitle(searchFlow!.tempCourse!.name, subtitle: "\(subject!.season.capitalizedString) \(subject!.year)")
        
        navigationItem.title = searchFlow!.tempCourse!.name
        
    }

    override func viewWillAppear(animated: Bool) {
        if appeared {
            if searchFlow?.tempSection?.status == "Open" {
                self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.openSection
            } else {
                self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.closedSection
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barTintColor = previousColor
    }
    
    // MARK: - Navigation
    
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate) {
        searchFlow?.buildSubscription()
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
                let switchView = UISwitch(frame:CGRectMake(150, 300, 0, 0));
                switchView.onTintColor = AppConstants.Colors.primary
                switchView.on = true
                switchView.setOn(true, animated: false);
                switchView.addTarget(self, action: #selector(switchValueDidChange), forControlEvents: .ValueChanged);
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
        if (sender.on == true){
            print("User subscribe")
        }
        else{
            print("User unsubscribed")
        }
    }
}