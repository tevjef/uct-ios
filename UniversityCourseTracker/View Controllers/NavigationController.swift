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
        self.navigationBar.barTintColor = AppConstants.Colors.primary

        // Status bar white font
        self.navigationBar.barStyle = UIBarStyle.Black
        self.navigationBar.tintColor = UIColor.whiteColor()
    }


    //Changing Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if self.visibleViewController is DefaultsViewController {
            return UIStatusBarStyle.Default
        } else {
            return UIStatusBarStyle.LightContent
        }
    }
}