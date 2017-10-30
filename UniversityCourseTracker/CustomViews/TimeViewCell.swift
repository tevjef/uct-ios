//
//  TableViewCell.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/7/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit
import CocoaLumberjack

class TimeViewCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    var meetingViews: [MeetingView] = []
    static var maxMeetingViews = 20
    
    override func awakeFromNib() {
        super.awakeFromNib()
        AppConstants.Colors.configureLabel(title, style: AppConstants.FontStyle.headline)
        
        for view in meetingViews {
            stackView.addArrangedSubview(view)
            view.autoPinEdge(toSuperviewEdge: .trailing)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for _ in 0..<TimeViewCell.maxMeetingViews {
            let meetingView = MeetingView.createMeetingView()
            meetingView.tag = MeetingView.TAG
            self.meetingViews.append(meetingView)
        }
    }
    
    
    func setMeetings(_ section: Section) {
        var height: CGFloat = 0
        for index in 0..<section.meetings.count {
            if index > TimeViewCell.maxMeetingViews - 1 {
                DDLogError("More than \(SectionViewCell.maxMeetingViews) meetings found for \(section.topicName)")
                return
            }
            
            height += 15
            let meeting = section.meetings[index]
            let meetingView = meetingViews[index]
            
            if meeting.day != "" {
                meetingView.dayView.text = meeting.day
            } else {
                meetingView.dayView.text = meeting.classType
            }
            
            if meeting.startTime != "" {
                meetingView.timeView.text = meeting.startTime + " - " + meeting.endTime
            }
            
            meetingView.locationView.text = meeting.room
        }

        stackViewHeight.constant = height
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
