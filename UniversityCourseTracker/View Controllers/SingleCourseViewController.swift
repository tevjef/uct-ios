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
    
    // HeaderView that contains a segmented control
    var headerContainer: UIView?
    var header: UIView?
    var courseHeader: CourseHeaderView?
    
    // Filtered to contained only open sections
    var filteredCourse: Course?

    var loadedCourse: Course? {
        didSet {
            eagerSetupWith(loadedCourse!)
            self.tableView.reloadData()
        }
    }
    
    // Datasource for the sections
    var sectionDataSource: Course?
    
    // Datasource for metadata
    var metadataDataSource: Course?

    override func viewDidLoad() {
        reporting.logShowScreen(self)

        setupViews()
        loadData()
    }
    
    func setupViews() {
        // Set navbar title e.g English Composition - 101
        title = "\(searchFlow!.tempCourse!.number): \(searchFlow!.tempCourse!.name)"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45
        
        tableView.registerNib(UINib(nibName: "SectionViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: sectionCellIdentifier)
        tableView.registerNib(UINib(nibName: "MetadataCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: metadataCellIdentifier)
        
        // Headerview setup
        headerContainer = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 45))
        header = UIView.init(frame: headerContainer!.bounds)
        header?.backgroundColor = AppConstants.Colors.primary
        headerContainer?.addSubview(header!)
        
        courseHeader = CourseHeaderView.createView()
        courseHeader!.segmentedControl.addTarget(self, action: #selector(segmentedControlAction), forControlEvents: .ValueChanged)
        header?.addSubview(courseHeader!)
        courseHeader!.autoPinEdgesToSuperviewEdges()
        courseHeader!.sizeToFit()
        tableView.tableHeaderView = headerContainer
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_bell_white"), style: .Plain, target: self, action: #selector(popToRoot))

    }
    
    
    // Loaded data from the network silently
    func loadData() {
        eagerSetupWith(searchFlow!.tempCourse!)
        datarepo.getCourse(searchFlow!.courseTopicName!, {
            if let course = $0 {
                self.loadedCourse = course
            }
        })
    }
    
    func eagerSetupWith(course: Course) {
        let sections = course.sections.filter({
            section in
            return section.status == "Open"
        })
        
        do {
            let newCourse = try Course.Builder().mergeFrom(course).setSections(sections).build()
            filteredCourse = newCourse
        } catch {
            Timber.e("Error while filtering sections from course \(error)")
        }
        
        sectionDataSource = course
        courseHeader?.segmentedControl.selectedSegmentIndex = 1
        
        metadataDataSource = course
    }

    
    // Tableview header gets fucked up in landscape, this should set it right.
    override func viewDidLayoutSubviews() {
        header?.bounds = CGRectMake(0,0, (headerContainer?.bounds.size.width)!, (headerContainer?.bounds.size.height)!)
        header?.frame.origin.x = 0
    }
    
    // Keep the header at the top of the view
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsety = scrollView.contentOffset.y
        header?.transform = CGAffineTransformMakeTranslation(0, offsety)
    }
    
    // Listens to the changes in the segmented control
    func segmentedControlAction(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            sectionDataSource = filteredCourse
            reporting.logFilterOpenSections(sectionDataSource!.topicId, count: sectionDataSource!.sections.count)
        } else if sender.selectedSegmentIndex == 1 {
            sectionDataSource = loadedCourse
            reporting.logFilterAllSections(sectionDataSource!.topicId, count: sectionDataSource!.sections.count)
        }
        
        tableView.beginUpdates()
        tableView.reloadSections(NSIndexSet.init(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView.endUpdates()
    }
    
    
    // MARK: - UITableViewDelegate Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return metadataDataSource?.metadata.count ?? 0

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
                let modelItem = metadataDataSource?.metadata[indexPath.row]
                cell.title.text = modelItem?.title
                
                var contentString = modelItem?.content
                contentString = contentString!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                cell.content.text = contentString
                
                return cell
            }
        } else if indexPath.section == 1 {
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
        // Set back button for next controller
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "\(loadedCourse!.number)", style: .Plain, target: nil, action: nil)
        prepareSearchFlow(sectionVC)
        self.navigationController?.showViewController(sectionVC, sender: self)
    }
    
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate) {
        let section = sectionDataSource!.sections[selectedIndex]
        searchFlow?.sectionTopicName = section.topicName
        searchFlow?.tempSection = section
        searchFlowDelegate.searchFlow = searchFlow
    }
}