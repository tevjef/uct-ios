//
//  SectionHeaderView.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/8/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class SectionHeaderView: UIView {

    @IBOutlet weak var sectionNumber: UILabel!
    @IBOutlet weak var callNumber: UILabel!
    @IBOutlet weak var creditsNumber: UILabel!
    @IBOutlet weak var instructorText: UILabel!
    @IBOutlet weak var semesterText: UILabel!
    
    static let viewNib: UINib = UINib(nibName: "SectionHeaderView", bundle: NSBundle.mainBundle())
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    class func createView() -> SectionHeaderView {
        return SectionHeaderView.viewNib.instantiateWithOwner(self, options: nil).first as! SectionHeaderView
    }
    
    func setSection(section: Common.Section, semester: Common.Semester) {
        sectionNumber.text = section.number
        callNumber.text = section.callNumber
        creditsNumber.text = section.credits
        instructorText.text = Common.getReadableInstructor(section.instructors)
        semesterText.text = Common.getReadableSemester(semester)
    }

}
