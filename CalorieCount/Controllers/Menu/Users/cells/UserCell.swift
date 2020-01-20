//
//  UserCellTableViewCell.swift
//  CalorieCount
//
//  Created by Terence Zama on 28/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
import SwipeCellKit

class UserCell: SwipeTableViewCell {
    @IBOutlet weak var userCircularView: CircularView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var badgeLabel: BadgeLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
