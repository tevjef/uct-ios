//
//  NoSections.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/19/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class NoSections: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    static let viewNib: UINib = UINib(nibName: "NoSections", bundle: Bundle.main)


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        AppConstants.Colors.configureLabel(textLabel, style: .headline)
    }
    
    class func createView() -> NoSections {
        return NoSections.viewNib.instantiate(withOwner: self, options: nil).first as! NoSections
    }
}
