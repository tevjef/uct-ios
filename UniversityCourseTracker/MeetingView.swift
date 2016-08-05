//
//  MeetingView.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/4/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class MeetingView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var dayView: UILabel!
    @IBOutlet weak var timeView: UILabel!
    @IBOutlet weak var locationView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
