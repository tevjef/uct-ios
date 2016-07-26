//
//  UniversityListViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class TermViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var loadedTerms: Array<Common.Semester>?
    var selectedTerm: Int = -1
    var searchProtocol: SearchFlowProtocol?

    override func viewDidLoad() {
        tableView.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedTerms!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = Common.getReadableString(loadedTerms![indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedTerm = indexPath.row
        if selectedTerm != -1 {
            searchProtocol!.setTerm(self.loadedTerms![selectedTerm])
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}