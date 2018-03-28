//
//  CarBookingModelController.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/24/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

// Iniitialize Model used to hold Booking Request and Result

import Foundation

class CarBookingModelController {
    
    var bookRequest = BookRequest(
        carId: "",
        rentalDays: [],
        carPrice: 0
    )
    
    var bookResult = BookResult(
        carId: "",
        estPrice: "",
        confNum: ""
    )
}
