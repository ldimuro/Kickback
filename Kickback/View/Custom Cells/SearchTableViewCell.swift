//
//  SearchTableViewCell.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/24/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//


import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
