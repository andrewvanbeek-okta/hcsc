//
//  TokenDetailTableViewCell.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 12/4/17.
//  Copyright © 2017 Joe Burgett. All rights reserved.
//

// Define Table View Cell used to Display Token Details in the OAuthViewController/Inspector View

import UIKit

class TokenDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var tokenElementName: UILabel!
    @IBOutlet weak var tokenElementDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
