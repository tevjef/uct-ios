//
//  SingleCourseViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/2/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class SingleCourseViewController: UITableViewController, SearchFlowDelegate {
    var searchFlow: SearchFlow?
    
    var selectedIndex: Int = 0
    
    var loadedCourse: Common.Course?
    var dummeyCourse: Common.Course? {
        didSet {
            //self.tableView.reloadData()

            //UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.reloadSections(NSIndexSet.init(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
            //UIView.setAnimationsEnabled(true)

            UIView.transitionWithView(tableView, duration: 0.1, options: .TransitionCrossDissolve, animations: {
                () -> Void in
                }, completion: nil);
        }
    }


    let metadataCellIdentifier = "metadataCell"
    let sectionCellIdentifier = "sectionCell"

    override func scrollViewDidScroll(scrollView: UIScrollView) {      
        let offsety = scrollView.contentOffset.y
        let headerContainer = tableView.tableHeaderView?.subviews[0]
        headerContainer?.transform = CGAffineTransformMakeTranslation(0, min(offsety, 0))
    }
    
    override func viewDidLoad() {
        title = loadedCourse?.name
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        let headerContainer = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 60))
        let header = UIView.init(frame: headerContainer.bounds)
        header.backgroundColor = AppConstants.Colors.primary
        headerContainer.addSubview(header)
        tableView.tableHeaderView = headerContainer

        tableView.registerNib(UINib(nibName: "SectionViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: sectionCellIdentifier)
        tableView.registerNib(UINib(nibName: "MetadataCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: metadataCellIdentifier)
        
        // A hack because UI code is shitty and slow to load, header view flickers
        let delayTime = loadedCourse?.sections.count > 6 ? 1 : 0.2
        delay(delayTime, closure: {
            self.dummeyCourse = self.loadedCourse
        })
    }
    
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate) {
        let section = loadedCourse!.sections[selectedIndex]
        searchFlow?.sectionTopicName = section.topicName
        searchFlow?.tempSection = section
        
        searchFlowDelegate.searchFlow = searchFlow
    }

    // MARK: - UITableViewDelegate Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return loadedCourse?.metadata.count ?? 0

        } else {
            return dummeyCourse?.sections.count ?? 0
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell: MetadataCell = tableView.dequeueReusableCellWithIdentifier(metadataCellIdentifier) as? MetadataCell {
                cell.userInteractionEnabled = false
                let modelItem = loadedCourse?.metadata[indexPath.row]
                cell.title.text = modelItem?.title
                
                var contentString = modelItem?.content
                contentString = contentString!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                cell.content.text = contentString
                
                return cell
            }
        } else {
            
            if let cell: SectionViewCell = tableView.dequeueReusableCellWithIdentifier(sectionCellIdentifier) as? SectionViewCell {
                let modelItem = dummeyCourse!.sections[indexPath.row]
                cell.setSection(modelItem)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedIndex = indexPath.row
        gotoSection()
    }

    func gotoSection() {
        let sectionVC = self.storyboard?.instantiateViewControllerWithIdentifier(AppConstants.Id.Controllers.section) as! SectionViewController
        //self.performSegueWithIdentifier(AppConstants.Id.Segue.section, sender: nil)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        prepareSearchFlow(sectionVC)
        self.navigationController?.showViewController(sectionVC, sender: self)

    }
}