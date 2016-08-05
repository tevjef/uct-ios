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

    @IBOutlet weak var sunday: UIView!
    @IBOutlet weak var monday: UIView!
    @IBOutlet weak var tuesday: UIView!
    @IBOutlet weak var wednesday: UIView!
    @IBOutlet weak var thursday: UIView!
    @IBOutlet weak var friday: UIView!
    @IBOutlet weak var sectionNumber: UILabel!
    
    var containers: [UIView] = []
    var meetingNib: UINib?
    override func awakeFromNib() {
        super.awakeFromNib()
        containers.append(sunday)
        containers.append(monday)
        containers.append(tuesday)
        containers.append(wednesday)
        containers.append(thursday)
        containers.append(friday)
        circleViewContainer.layer.cornerRadius = circleViewContainer.frame.height / 2
        
        meetingNib = UINib(nibName: "MeetingView", bundle: nil)
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SectionViewCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    
    func createMeetingView() -> MeetingView {
        return meetingNib?.instantiateWithOwner(self, options: nil).first as! MeetingView
    }

    var previousCell: UIView?
    
    @IBOutlet weak var stackView: UIStackView!
    
    func setSection(section: Common.Section) {
        sectionNumber.text = section.number
        if section.status == "Open" {
            circleViewContainer.backgroundColor = UIColor(hexString: "4CAF50")
        } else {
            circleViewContainer.backgroundColor = UIColor(hexString: "F44336")
        }
        var height: CGFloat = 0
        for index in 0..<section.meetings.count {
            height += 15
            containers[index].subviews.forEach({ $0.removeFromSuperview() })
            let meeting = section.meetings[index]
            let view = createMeetingView()
            containers[index].addSubview(view)
            view.configureForAutoLayout()
            view.autoPinEdgesToSuperviewEdges()
            view.updateConstraintsIfNeeded()
            //print("Constaints", view.constraints)
            if meeting.day != "" {
                let abbrIndex = meeting.day.startIndex.advancedBy(3)
                view.dayView.text = meeting.day.substringToIndex(abbrIndex)

            } else {
                view.dayView.text = meeting.classType
            }
            
            if meeting.startTime != "" && meeting.endTime != "" {
                view.timeView.text = meeting.startTime + " " + meeting.endTime
            } else {
                view.timeView.text = ""
            }
            
            view.locationView.text = meeting.room
        }
        stackView.clipsToBounds = true
        stackViewHeight.constant = max(circleViewHeight.constant, height)
    }
    
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var circleViewHeight: NSLayoutConstraint!
    
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
