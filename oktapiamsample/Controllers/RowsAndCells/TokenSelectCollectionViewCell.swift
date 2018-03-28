//
//  TokenSelectCollectionViewCell.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 12/4/17.
//  Copyright © 2017 Joe Burgett. All rights reserved.
//

// Define Collection View Cell used to Display Token Typesm in the OAuthViewController/Inspector View

import UIKit

class TokenSelectCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tokenSelectCellLabel: UILabel!
    //  Test Button Placeholder. TBD if this will be used to call the Introspection Endpoint to Validate the Token
    @IBOutlet weak var testButton: UIButton!
    
}
