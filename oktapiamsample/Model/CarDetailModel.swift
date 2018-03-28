//
//  CarDetailModel.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/18/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

// Model used to display selected vechicle in CarDetailViewController

import Foundation

struct CarDetail {
    let id: String
    let make: String
    let model: String
    let carClass: String
    let avail: String
    let desc: String
    let price: String
    let imgUrl: String
}
