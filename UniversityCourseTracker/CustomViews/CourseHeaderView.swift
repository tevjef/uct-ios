//
//  CourseHeaderView.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/8/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class CourseHeaderView: UIView {

    static let headerViewHeight: CGFloat = 50.0
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    static let viewNib: UINib = UINib(nibName: "CourseHeaderView", bundle: Bundle.main)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        self.backgroundColor = AppConstants.Colors.primary
        super.awakeFromNib()
    }
    
    class func createView() -> CourseHeaderView {
        return CourseHeaderView.viewNib.instantiate(withOwner: self, options: nil).first as! CourseHeaderView
    }
}
