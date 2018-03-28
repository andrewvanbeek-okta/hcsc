//
//  CarCellModel.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/17/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

// Model used to populate cell in Inventory Collection View

import Foundation

class CarCellModel {
    
    var carId: String
    var carMake: String
    var carModel: String
    var carPrice: String
    var carImageUrl: String
    var carClass: String
    var carAvail: String
    var carDesc: String
    
    init(id: String, make: String, model: String, price: String , image: String, carClass: String, avail: String, desc: String) {
        
        self.carId = id
        self.carMake = make
        self.carModel = model
        self.carPrice = price
        self.carImageUrl = image
        self.carClass = carClass
        self.carAvail = avail
        self.carDesc = desc
        
    }
}
