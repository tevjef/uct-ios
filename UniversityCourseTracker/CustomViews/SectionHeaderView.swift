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

    static let viewNib: UINib = UINib(nibName: "SectionHeaderView", bundle: Bundle.main)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    class func createView() -> SectionHeaderView {
        return SectionHeaderView.viewNib.instantiate(withOwner: self, options: nil).first as! SectionHeaderView
    }
    
    func setSection(_ section: Section, semester: Semester) {
        sectionNumber.text = section.number
        callNumber.text = section.callNumber
        
        if section.credits == "-1" {
            creditsNumber.text = "N/A"
        } else {
            creditsNumber.text = section.credits
        }
        
        instructorText.text = section.instructors.listString
        semesterText.text = semester.readableString
    }

}
