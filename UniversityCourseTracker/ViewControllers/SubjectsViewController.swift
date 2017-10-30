//
//  SubjectsViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class SubjectsViewController: UITableViewController, SearchFlowDelegate {

    var loadedSubjects: Array<Subject>? {
        didSet {
            if loadedSubjects?.count == oldValue?.count {
                return
            }
            
            UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                () -> Void in
                    self.tableView.reloadData()
            }, completion: nil);
        }
    }
    
    var searchFlow: SearchFlow?

    override func viewDidLoad() {
        searchFlow = SearchFlow()
        refreshSearchFlow()
        reporting.logShowScreen(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchFlow = SearchFlow()
        refreshSearchFlow()
        setupViews()
        loadData(true)
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        loadData(false)
    }
    
    func loadData(_ showLoading: Bool) {
        if showLoading {
            showRefreshing{self.loadedSubjects == nil || self.loadedSubjects?.count == 0}
        }
        refreshSearchFlow()
        
        datarepo.getSubjects(searchFlow!.universityTopicName!, searchFlow!.season!, searchFlow!.year!, { [weak self]
            subjects in
            self?.hideRefreshing()
            if let subjects = subjects {
                self?.loadedSubjects = subjects
            } else {
                // Alert no internet
                self?.alertNoInternet({
                    self?.showRefreshing()
                    // Wait n seconds then retry loading, if user hasn't navigated away
                    self?.delay(5, closure: {
                        self?.loadData(true)
                    })
                })
            }
        })
    }

    func setupViews() {
        let semesterString = coreData.semester!.readableString
        let uni = coreData.university?.abbr ?? "Err"
        
        self.refreshControl?.tintColor = AppConstants.Colors.primary

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //let titleView = self.makeTitleViewWithSubtitle(semester, subtitle: uni)
        //navigationItem.titleView = titleView
        navigationItem.title = uni +  " " + semesterString
    }
    
    func refreshSearchFlow() {
        searchFlow!.universityTopicName = coreData.university?.topicName
        searchFlow!.season = coreData.semester?.season
        searchFlow!.year = coreData.semester?.year.description
        searchFlow!.tempSemester = coreData.semester!
        searchFlow!.tempUniversity = coreData.university
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == AppConstants.Id.Segue.courses {
            let nextViewController = segue.destination as! CoursesViewController
            prepareSearchFlow(nextViewController)
        }
    }
    
    func prepareSearchFlow(_ searchFlowDelegate: SearchFlowDelegate) {
        let selectedRow = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row
        let subject = loadedSubjects?[selectedRow!]
        searchFlow?.tempSubject = subject
        searchFlow?.subjectTopicName = subject?.topicName
        searchFlowDelegate.searchFlow = self.searchFlow
    }
    
    // MARK: - UITableViewDelegate Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedSubjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subjectCell", for: indexPath) as UITableViewCell
        AppConstants.Colors.configureLabel(cell.textLabel!, style: AppConstants.FontStyle.body)
        cell.selectedBackgroundView = AppConstants.Colors.primaryLight.viewFromColor()
        
        let subject = loadedSubjects?[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = "\(subject?.number ?? ""): \(subject?.name ?? "")"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
