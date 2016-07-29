//
//  NavBarController.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/27/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController, UIViewControllerTransitioningDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.translucent = false
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.barTintColor = UIColor(hexString: "#607D8B")

        // Status bar white font
        self.navigationBar.barStyle = UIBarStyle.Black
        self.navigationBar.tintColor = UIColor(hexString: "#CFD8DC")
    }
}