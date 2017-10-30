//
//  SectionViewCell.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/3/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit
import PureLayout
import CocoaLumberjack

class SectionViewCell: UITableViewCell {

    @IBOutlet weak var circleViewContainer: UIView!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var circleViewHeight: NSLayoutConstraint!

    @IBOutlet weak var sectionNumber: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    
    var meetingViews: [MeetingView] = []
    static var maxMeetingViews = 7
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = AppConstants.Colors.primaryLight.viewFromColor()
        AppConstants.Colors.configureLabel(instructorLabel, style: AppConstants.FontStyle.caption)
        
        for view in meetingViews {
            stackView.addArrangedSubview(view)
            view.autoPinEdge(toSuperviewEdge: .trailing)
        }
        circleViewContainer.layer.cornerRadius = circleViewContainer.frame.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for _ in 0..<SectionViewCell.maxMeetingViews {
            let meetingView = MeetingView.createMeetingView()
            meetingView.tag = MeetingView.TAG
            self.meetingViews.append(meetingView)
        }
    }


    
    func resetAllMeetingViews() {
        for view in meetingViews {
            let meetingView = view.viewWithTag(MeetingView.TAG) as! MeetingView
            meetingView.resetViews()
        }
    }
    
    func setSection(_ section: Section) {
        sectionNumber.text = section.number
        if section.status == "Open" {
            circleViewContainer.backgroundColor = AppConstants.Colors.openSection
        } else {
            circleViewContainer.backgroundColor = AppConstants.Colors.closedSection
        }
        
        instructorLabel.text = section.instructors.listString
        
        var height: CGFloat = 0
        resetAllMeetingViews()
        for index in 0..<section.meetings.count {
            if index > SectionViewCell.maxMeetingViews - 1 {
                DDLogError("More than \(SectionViewCell.maxMeetingViews) meetings found for \(section.topicName)")
                return
            }

            height += 15
            let meeting = section.meetings[index]
            let meetingView = meetingViews[index]

            if meeting.day != "" {
                let abbrIndex = meeting.day.characters.index(meeting.day.startIndex, offsetBy: 3)
                meetingView.dayView.text = meeting.day.substring(to: abbrIndex)

            } else {
                meetingView.dayView.text = meeting.classType
            }
            
            if meeting.startTime != "" {
                meetingView.timeView.text = meeting.startTime + " - " + meeting.endTime
            }
            
            meetingView.locationView.text = meeting.room
        }
        
        stackViewHeight.constant = max(circleViewHeight.constant, height)
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = circleViewContainer.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if(selected) {
            circleViewContainer.backgroundColor = color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = circleViewContainer.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if(highlighted) {
            circleViewContainer.backgroundColor = color
        }
    }
}
