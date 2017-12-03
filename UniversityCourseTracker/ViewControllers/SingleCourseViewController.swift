//
//  SingleCourseViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/2/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit
import CocoaLumberjack

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
        title = "\(searchFlow!.tempCourse!.number!): \(searchFlow!.tempCourse!.name!)"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45
        
        tableView.register(UINib(nibName: "SectionViewCell", bundle: Bundle.main), forCellReuseIdentifier: sectionCellIdentifier)
        tableView.register(UINib(nibName: "MetadataCell", bundle: Bundle.main), forCellReuseIdentifier: metadataCellIdentifier)
        
        // Headerview setup
        headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: CourseHeaderView.headerViewHeight))
        header = UIView.init(frame: headerContainer!.bounds)
        header?.backgroundColor = AppConstants.Colors.primary
        headerContainer?.addSubview(header!)
        
        courseHeader = CourseHeaderView.createView()
        courseHeader!.segmentedControl.addTarget(self, action: #selector(segmentedControlAction), for: .valueChanged)
        header?.addSubview(courseHeader!)
        courseHeader!.autoPinEdgesToSuperviewEdges()
        courseHeader!.sizeToFit()
        tableView.tableHeaderView = headerContainer
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: CourseHeaderView.headerViewHeight,left: 0,bottom: 0,right: 0)

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_bell_white"), style: .plain, target: self, action: #selector(popToRoot))

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
    
    func eagerSetupWith(_ course: Course) {
        let sections = course.sections.filter({
            section in
            return section.status == "Open"
        })
        
        do {
            let newCourse = try Course.Builder().mergeFrom(other: course).setSections(sections).build()
            filteredCourse = newCourse
        } catch {
            DDLogError("Error while filtering sections from course \(error)")
        }
        
        sectionDataSource = course
        courseHeader?.segmentedControl.selectedSegmentIndex = 1
        
        metadataDataSource = course
    }

    
    // Tableview header gets fucked up in landscape, this should set it right.
    override func viewDidLayoutSubviews() {
        header?.bounds = CGRect(x: 0,y: 0, width: (headerContainer?.bounds.size.width)!, height: (headerContainer?.bounds.size.height)!)
        header?.frame.origin.x = 0
    }
    
    // Keep the header at the top of the view
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsety = scrollView.contentOffset.y
        header?.transform = CGAffineTransform(translationX: 0, y: offsety)
    }
    
    // Listens to the changes in the segmented control
    func segmentedControlAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            sectionDataSource = filteredCourse
            reporting.logFilterOpenSections(sectionDataSource!.topicId, count: sectionDataSource!.sections.count)
        } else if sender.selectedSegmentIndex == 1 {
            sectionDataSource = loadedCourse
            reporting.logFilterAllSections(sectionDataSource!.topicId, count: sectionDataSource!.sections.count)
        }
        
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet.init(integer: 1), with: UITableViewRowAnimation.automatic)
        tableView.endUpdates()
    }
    
    
    // MARK: - UITableViewDelegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return metadataDataSource?.metadata.count ?? 0

        } else {
            return sectionDataSource?.sections.count ?? 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            if let cell: MetadataCell = tableView.dequeueReusableCell(withIdentifier: metadataCellIdentifier) as? MetadataCell {
                cell.isUserInteractionEnabled = false
                let modelItem = metadataDataSource?.metadata[(indexPath as NSIndexPath).row]
                cell.title.text = modelItem?.title
                
                var contentString = modelItem?.content
                contentString = contentString!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                cell.content.text = contentString
                
                return cell
            }
        } else if (indexPath as NSIndexPath).section == 1 {
            if let cell: SectionViewCell = tableView.dequeueReusableCell(withIdentifier: sectionCellIdentifier) as? SectionViewCell {
                let modelItem = sectionDataSource!.sections[(indexPath as NSIndexPath).row]
                cell.setSection(modelItem)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = (indexPath as NSIndexPath).row
        gotoSection()
    }

    func gotoSection() {
        let sectionVC = self.storyboard?.instantiateViewController(withIdentifier: AppConstants.Id.Controllers.section) as! SectionViewController
        // Set back button for next controller
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "\(searchFlow!.tempCourse!.number!)", style: .plain, target: nil, action: nil)
        prepareSearchFlow(sectionVC)
        self.navigationController?.show(sectionVC, sender: self)
    }
    
    func prepareSearchFlow(_ searchFlowDelegate: SearchFlowDelegate) {
        let section = sectionDataSource!.sections[selectedIndex]
        searchFlow?.sectionTopicName = section.topicName
        searchFlow?.tempSection = section
        searchFlowDelegate.searchFlow = searchFlow
    }
}
