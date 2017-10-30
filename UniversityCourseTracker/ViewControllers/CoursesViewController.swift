//
//  SubjectsViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class CoursesViewController: UITableViewController, SearchFlowDelegate {
    
    var loadedCourses: Array<Course>? {
        didSet {
            if loadedCourses?.count == oldValue?.count {
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
        reporting.logShowScreen(self)

        setupViews()
        loadData(true)
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        loadData(false)
    }
    
    func loadData(_ showLoading: Bool) {
        if showLoading {
            showRefreshing{ self.loadedCourses == nil || self.loadedCourses?.count == 0 }
        }
        
        datarepo.getCourses(searchFlow?.subjectTopicName ?? "", { [weak self]
            courses in
            self?.hideRefreshing()
            if let courses = courses {
                self?.loadedCourses = courses
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
        navigationItem.title = "\(searchFlow!.tempSubject!.number): \(searchFlow!.tempSubject!.name)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_bell_white"), style: .plain, target: self, action: #selector(popToRoot))
        
        self.refreshControl?.tintColor = AppConstants.Colors.primary
    }
    
    func prepareSearchFlow(_ searchFlowDelegate: SearchFlowDelegate) {
        let course = loadedCourses![(tableView.indexPathForSelectedRow! as NSIndexPath).row]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: searchFlow!.tempSubject!.number, style: .plain, target: nil, action: nil)
        searchFlow?.courseTopicName = course.topicName
        searchFlow?.tempCourse = course
        searchFlowDelegate.searchFlow = self.searchFlow
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == AppConstants.Id.Segue.sections {
            let nextViewController = segue.destination as! SingleCourseViewController
            prepareSearchFlow(nextViewController)
        }
    }

    // MARK: - UITableViewDelegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedCourses?.count ?? 0
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as UITableViewCell
        AppConstants.Colors.configureLabel(cell.textLabel!, style: AppConstants.FontStyle.body)
        AppConstants.Colors.configureLabel(cell.detailTextLabel!, style: AppConstants.FontStyle.body)
        cell.selectedBackgroundView = AppConstants.Colors.primaryLight.viewFromColor()

        let course = loadedCourses?[(indexPath as NSIndexPath).row]
        
        if course == nil {
            return cell
        }
        
        cell.textLabel?.text = "\(course!.number): \(course!.name)"
        cell.detailTextLabel?.text = "\(course!.openSections) open sections of \(course!.sections.count)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
