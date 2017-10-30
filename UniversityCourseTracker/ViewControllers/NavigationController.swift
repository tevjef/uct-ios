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

        self.navigationBar.isTranslucent = false
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.barTintColor = AppConstants.Colors.primary

        // Status bar white font
        self.navigationBar.barStyle = UIBarStyle.black
        self.navigationBar.tintColor = UIColor.white
    }


    //Changing Status Bar
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if self.visibleViewController is DefaultsViewController {
            return UIStatusBarStyle.default
        } else {
            return UIStatusBarStyle.lightContent
        }
    }
}
