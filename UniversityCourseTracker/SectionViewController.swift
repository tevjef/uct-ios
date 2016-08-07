//
//  ViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class SectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchFlowDelegate {
    var searchFlow: SearchFlow?
    let metadataCellIdentifier = "metadataCell"
    let timeCellIdentifier = "timeCell"
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        setupViews()
        // Do any additional setup after loading the view, typically from a nib.
    
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = CGPointZero;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Fit tableview under navigation bar
    override func viewDidLayoutSubviews() {
        if let rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            self.tableView.contentInset = UIEdgeInsetsMake( y, 0, 0, 0)
        }
    }

    func setupViews() {
        previousColor = navigationController?.navigationBar.barTintColor

        if searchFlow?.tempSection?.status == "Open" {
            self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.openSection
        } else {
            self.navigationController?.navigationBar.barTintColor = AppConstants.Colors.closedSection
        }

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        tableView.registerNib(UINib(nibName: "TimeViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: timeCellIdentifier)
        tableView.registerNib(UINib(nibName: "MetadataCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: metadataCellIdentifier)

    
        //let subject = searchFlow?.tempSubject
        //let titleView = self.makeTitleViewWithSubtitle(searchFlow!.tempCourse!.name, subtitle: "\(subject!.season.capitalizedString) \(subject!.year)")
        
        navigationItem.title = searchFlow!.tempCourse!.name
        
    }
    
    var previousColor: UIColor?

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barTintColor = previousColor
    }
    
    // MARK: - Navigation
    
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate) {
        searchFlow?.buildSubscription()
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return searchFlow?.tempSection?.metadata.count ?? 0
            
        } else {
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell: MetadataCell = tableView.dequeueReusableCellWithIdentifier(metadataCellIdentifier) as? MetadataCell {
                cell.userInteractionEnabled = false
                let modelItem = searchFlow?.tempSection?.metadata[indexPath.row]
                cell.title.text = modelItem?.title
                
                var contentString = modelItem?.content
                contentString = contentString!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                cell.content.text = contentString
                
                return cell
            }
        } else {
            
            if let cell: TimeViewCell = tableView.dequeueReusableCellWithIdentifier(sectionCellIdentifier) as? SectionViewCell {
                //let modelItem = dummeyCourse!.sections[indexPath.row]
                //cell.setSection(modelItem)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //selectedIndex = indexPath.row
    }
}