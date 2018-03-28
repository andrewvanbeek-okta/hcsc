//
//  CarBookingModel.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/24/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

// Model used to hold Booking Request and Result

import Foundation

struct BookRequest {
    let carId: String
    let rentalDays: Array<Any>
    let carPrice: Int
}

struct BookResult {
    let carId: String
    let estPrice: String
    let confNum: String
}
