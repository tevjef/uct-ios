//
//  ViewController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        setupViews()
        // Do any additional setup after loading the view, typically from a nib.
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    static func makeActivityIndicator(view: UIView) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = view.center
        view.addSubview(indicator)
        return indicator
    }

    static func startIndicator(indicator: UIActivityIndicatorView) {
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.whiteColor()
    }

    static func stopIndicator(indicator: UIActivityIndicatorView) {
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
    }
    
    func setupViews() {
        navigationItem.title = "Tracked Courses"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
    }
}