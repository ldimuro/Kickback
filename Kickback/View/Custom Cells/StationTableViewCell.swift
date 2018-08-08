//
//  StationTableViewCell.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/17/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

//  Profile Icon made by Smashicon [https://www.flaticon.com/authors/smashicons] from www.flaticon.com
//  Music-note Icon made by Smashicon [https://www.flaticon.com/authors/smashicons] from www.flaticon.com

import UIKit
import SwipeCellKit

class StationTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var songCount: UILabel!
    @IBOutlet weak var userCount: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
