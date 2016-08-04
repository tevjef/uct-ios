//
//  SectionViewCell.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/3/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit
import PureLayout

class SectionViewCell: UITableViewCell {

    @IBOutlet weak var circleViewContainer: UIView!
    @IBOutlet weak var meetingTimeContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //var label = UILabel(frame: CGRectMake(0, 0, 200, 21))
        //meetingTimeContainer.addSubview(label)

        //label.center = CGPointMake(160, 284)
        //label.textAlignment = NSTextAlignment.Center
        //label.text = "I'am a test label"
        //label.backgroundColor =  UIColor.grayColor()
        

    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SectionViewCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
