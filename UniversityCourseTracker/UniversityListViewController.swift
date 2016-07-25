//
//  UniversityListViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class UniversityListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var universityList: [String] = []
    var indicator = UIActivityIndicatorView()
    var loadedUniversities: Array<Common.University>?
    var selectedUniversity: Int = -1
    var searchProtocol: SearchFlowProtocol?
    
    override func viewDidLoad() {
        activityIndicator()
        startIndicator()
        getUniversities { (unis: Array<Common.University>?) in
            if let unis = unis {
                self.loadedUniversities = unis
                for u in unis {
                    self.universityList.append(u.name)
                }
                self.tableView.reloadData()
                self.stopIndicator()
            } else {
                print("Error")
            }
        }
    }

    func startIndicator() {
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.whiteColor()
    }
    
    func stopIndicator() {
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return universityList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = universityList[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedUniversity = indexPath.row
        if selectedUniversity != -1 {
            searchProtocol!.setUniversity(self.loadedUniversities![selectedUniversity])
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}