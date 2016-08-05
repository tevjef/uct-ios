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
    
    var loadedCourse: Common.Course?
    let metadataCellIdentifier = "metadataCell"
    let sectionCellIdentifier = "sectionCell"

    override func viewDidLoad() {
        title = loadedCourse?.name
        
        tableView.registerNib(UINib(nibName: "SectionViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: sectionCellIdentifier)
        tableView.registerNib(UINib(nibName: "MetadataCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: metadataCellIdentifier)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 43.5
    }
    
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate) {
        
    }

    // MARK: - UITableViewDelegate Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return loadedCourse?.metadata.count ?? 0

        } else {
            return loadedCourse?.sections.count ?? 0
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
                
                // Make sure the constraints have been added to this cell, since it may have just been created from scratch
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                
                return cell
            }
        } else {
            if let cell: SectionViewCell = tableView.dequeueReusableCellWithIdentifier(sectionCellIdentifier) as? SectionViewCell {
                let modelItem = loadedCourse!.sections[indexPath.row]
                cell.setSection(modelItem)
              cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}