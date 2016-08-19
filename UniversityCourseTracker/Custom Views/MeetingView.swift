//
//  MeetingView.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/4/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class MeetingView: UIView {
   
    static let TAG: Int = 100
    @IBOutlet weak var dayView: UILabel!
    @IBOutlet weak var timeView: UILabel!
    @IBOutlet weak var locationView: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    static let meetingNib: UINib = UINib(nibName: "MeetingView", bundle: NSBundle.mainBundle())

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        AppConstants.Colors.configureLabel(dayView, style: AppConstants.FontStyle.Caption)
        AppConstants.Colors.configureLabel(timeView, style: AppConstants.FontStyle.Caption)
        AppConstants.Colors.configureLabel(locationView, style: AppConstants.FontStyle.Caption)

        resetViews()
    }
    
    class func createMeetingView() -> MeetingView {
        return MeetingView.meetingNib.instantiateWithOwner(self, options: nil).first as! MeetingView
    }
    
    func resetViews() {
        dayView.text = ""
        timeView.text = ""
        locationView.text = ""
    }
    
    func hasContent() -> Bool {
        return dayView.text != "" || timeView.text != "" || locationView.text != ""
    }

}
