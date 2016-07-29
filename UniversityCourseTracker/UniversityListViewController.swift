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
        setupViews()
        ViewController.startIndicator(indicator)

        // Load a list of universities from the network
        getUniversities { universities in
            if let universities = universities {
                self.loadedUniversities = universities
                for u in universities {
                    self.universityList.append(u.name)
                }
                self.tableView.reloadData()
                ViewController.stopIndicator(self.indicator)
            } else {
                let alert = UIAlertController(title: "No internet connection", message: "Please make sure you are connected to the internet", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { uiAction in self.goBack()                }))
                self.presentViewController(alert, animated: true, completion: nil)

            }
        }
    }

    func setupViews() {
        indicator = ViewController.makeActivityIndicator(self.view)
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
        goBack()
    }
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}