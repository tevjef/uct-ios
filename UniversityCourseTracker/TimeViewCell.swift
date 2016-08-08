//
//  TableViewCell.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/7/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class TimeViewCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    var meetingViews: [MeetingView] = []
    static var maxMeetingViews = 7
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for view in meetingViews {
            stackView.addArrangedSubview(view)
            view.autoPinEdgeToSuperviewEdge(.Trailing)
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
    
    
    func setMeetings(section: Common.Section) {
        var height: CGFloat = 0
        for index in 0..<section.meetings.count {
            if index > TimeViewCell.maxMeetingViews {
                Timber.e("More than \(SectionViewCell.maxMeetingViews) meetings found for \(section.topicName)")
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


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
