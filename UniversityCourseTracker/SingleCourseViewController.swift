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
    
    let metadataCellIdentifier = "metadataCell"
    let sectionCellIdentifier = "sectionCell"
    var headerContainer: UIView?
    var header: UIView?
    
    var loadedCourse: Common.Course? {
        didSet {
            let sections = loadedCourse?.sections.filter({
                section in
                return section.status == "Open"
            })
            
            do {
                let newCourse = try Common.Course.Builder().mergeFrom(loadedCourse!).setSections(sections!).build()
                filteredCourse = newCourse
            } catch {
                Timber.e("Error while filtering sections from course \(error)")
            }
        }
    }
    
    var filteredCourse: Common.Course?
    var sectionDataSource: Common.Course? {
        didSet {
            tableView.beginUpdates()
            tableView.reloadSections(NSIndexSet.init(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.endUpdates()
        }
    }
    
    override func viewDidLayoutSubviews() {
        // Tableview header gets fucked up in landscpare, this should set it right.
        header?.bounds = CGRectMake(0,0, (headerContainer?.bounds.size.width)!, (headerContainer?.bounds.size.height)!)
        header?.frame.origin.x = 0

        print("Header bounds=\(header!.bounds) frame=\(header!.frame)")
        print("Container bounds=\(headerContainer!.bounds) frame=\(headerContainer!.frame)")
        print("View bounds=\(view!.bounds) frame=\(view!.frame)")

    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {      
        let offsety = scrollView.contentOffset.y
        print(offsety)
        header?.transform = CGAffineTransformMakeTranslation(0, min(offsety, 0))
    }
    
    func segmentedControlAction(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            sectionDataSource = filteredCourse
        } else if sender.selectedSegmentIndex == 1 {
            sectionDataSource = loadedCourse
        }
    }
    
    override func viewDidLoad() {
        // Set navbar title e.g English Composition - 101
        title = "\(loadedCourse!.name) - \(loadedCourse!.number)"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45
        
        tableView.registerNib(UINib(nibName: "SectionViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: sectionCellIdentifier)
        tableView.registerNib(UINib(nibName: "MetadataCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: metadataCellIdentifier)
        
        // Headerview setup
        headerContainer = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 45))
        header = UIView.init(frame: headerContainer!.bounds)
        header?.backgroundColor = AppConstants.Colors.primary
        headerContainer?.addSubview(header!)
        
        let courseHeader = CourseHeaderView.createView()
        courseHeader.segmentedControl.addTarget(self, action: #selector(segmentedControlAction), forControlEvents: .ValueChanged)
        header?.addSubview(courseHeader)
        courseHeader.autoPinEdgesToSuperviewEdges()
        courseHeader.sizeToFit()
        tableView.tableHeaderView = headerContainer

        // Set default control postition. If there's lots of sections show a filtered list and at least 1 open section
        if loadedCourse?.sections.count > 10 && filteredCourse?.sections.count != 0 {
            sectionDataSource = filteredCourse
            courseHeader.segmentedControl.selectedSegmentIndex = 0
        } else {
            sectionDataSource = loadedCourse
            courseHeader.segmentedControl.selectedSegmentIndex = 1
        }
    }
    
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate) {
        let section = sectionDataSource!.sections[selectedIndex]
        searchFlow?.sectionTopicName = section.topicName
        searchFlow?.tempSection = section
        
        searchFlowDelegate.searchFlow = searchFlow
    }

    // MARK: - UITableViewDelegate Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return loadedCourse?.metadata.count ?? 0

        } else {
            return sectionDataSource?.sections.count ?? 0
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
                let modelItem = sectionDataSource!.sections[indexPath.row]
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
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        prepareSearchFlow(sectionVC)
        self.navigationController?.showViewController(sectionVC, sender: self)

    }
}