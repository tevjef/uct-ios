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
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var circleViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sunday: UIView!
    @IBOutlet weak var monday: UIView!
    @IBOutlet weak var tuesday: UIView!
    @IBOutlet weak var wednesday: UIView!
    @IBOutlet weak var thursday: UIView!
    @IBOutlet weak var friday: UIView!
    @IBOutlet weak var sectionNumber: UILabel!
    
    var containers: [UIView] = []
    var meetingNib: UINib = UINib(nibName: "MeetingView", bundle: nil)
    override func awakeFromNib() {
        super.awakeFromNib()
        containers.append(sunday)
        containers.append(monday)
        containers.append(tuesday)
        containers.append(wednesday)
        containers.append(thursday)
        containers.append(friday)
        
        for view in containers {
            let meetingView = createMeetingView()
            meetingView.tag = MeetingView.TAG

            view.addSubview(meetingView)
            meetingView.configureForAutoLayout()
            meetingView.autoPinEdgesToSuperviewEdges()
            view.updateConstraintsIfNeeded()
        }
        
        circleViewContainer.layer.cornerRadius = circleViewContainer.frame.height / 2
    }
    
    func createMeetingView() -> MeetingView {
        return meetingNib.instantiateWithOwner(self, options: nil).first as! MeetingView
    }
    
    func resetAllMeetingViews() {
        for view in containers {
            let meetingView = view.viewWithTag(MeetingView.TAG) as! MeetingView
            meetingView.resetViews()
        }
    }
    
    func setSection(section: Common.Section) {
        sectionNumber.text = section.number
        if section.status == "Open" {
            circleViewContainer.backgroundColor = AppConstants.Colors.openSection
        } else {
            circleViewContainer.backgroundColor = AppConstants.Colors.closedSection
        }
        
        var height: CGFloat = 0
        resetAllMeetingViews()
        for index in 0..<section.meetings.count {
            height += 15
            let meeting = section.meetings[index]
            let view = containers[index].viewWithTag(MeetingView.TAG) as! MeetingView
            
            if meeting.day != "" {
                let abbrIndex = meeting.day.startIndex.advancedBy(3)
                view.dayView.text = meeting.day.substringToIndex(abbrIndex)

            } else {
                view.dayView.text = meeting.classType
            }
            
            if meeting.startTime != "" {
                view.timeView.text = meeting.startTime + " - " + meeting.endTime
            }
            
            view.locationView.text = meeting.room
        }
        
        stackViewHeight.constant = max(circleViewHeight.constant, height)
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        let color = circleViewContainer.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if(selected) {
            circleViewContainer.backgroundColor = color
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let color = circleViewContainer.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if(highlighted) {
            circleViewContainer.backgroundColor = color
        }
    }
}
