//
//  MetadataCell.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/4/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import UIKit

class MetadataCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        AppConstants.Colors.configureLabel(title, style: AppConstants.FontStyle.Headline)
        AppConstants.Colors.configureLabel(content, style: AppConstants.FontStyle.Body)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
