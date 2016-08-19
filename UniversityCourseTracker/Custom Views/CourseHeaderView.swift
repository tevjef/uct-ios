//
//  CourseHeaderView.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/8/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class CourseHeaderView: UIView {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    static let viewNib: UINib = UINib(nibName: "CourseHeaderView", bundle: NSBundle.mainBundle())
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func createView() -> CourseHeaderView {
        return CourseHeaderView.viewNib.instantiateWithOwner(self, options: nil).first as! CourseHeaderView
    }
}
