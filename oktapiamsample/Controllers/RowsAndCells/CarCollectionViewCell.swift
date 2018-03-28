//
//  CarCollectionViewCell.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/29/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

// Define Collection View Cell used to Display Vehicle Details in the CarViewController View (Inventory List)

import UIKit
import Kingfisher

class CarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var makeTitle: UILabel!
    @IBOutlet weak var modelTitle: UILabel!
    @IBOutlet weak var priceTitle: UILabel!
    @IBOutlet weak var availTitle: UILabel!
    @IBOutlet weak var classTitle: UILabel!
    @IBOutlet weak var bookedLabel: UILabel!
    @IBOutlet weak var carImage: UIImageView!
    
    var model: CarCellModel! {
        didSet {
            self.updateView()
        }
    }
    
    func updateView() {
        
        // Testing Kingfisher Image Helper
        let placeImg = UIImage(named: "oktaWhite")
        let url = URL(string: self.model.carImageUrl)!
        self.carImage.kf.setImage(with: url, placeholder: placeImg)
        
        self.makeTitle.text = self.model.carMake
        self.modelTitle.text = self.model.carModel
        self.classTitle.text = self.model.carClass
        self.availTitle.text = self.model.carAvail
        self.priceTitle.text = "$\(self.model.carPrice) /day"
    }
}
