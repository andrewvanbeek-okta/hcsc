//
//  CarDetailModelController.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/18/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

// Initialize Model used to display selected vechicle in CarDetailViewController

import Foundation

class CarDetailModelController {
    
    var carDetail = CarDetail(
        id: "",
        make: "",
        model: "",
        carClass: "",
        avail: "",
        desc: "",
        price: "",
        imgUrl: ""
    )
}
