//
//  RiverUITableViewCell.swift
//  WheresTheWater
//
//  Created by Ben Marshall on 21/11/2014.
//  Copyright (c) 2014 Ben Marshall. All rights reserved.
//

import UIKit

class RiverUITableViewCell: UITableViewCell {
    @IBOutlet weak var stateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
