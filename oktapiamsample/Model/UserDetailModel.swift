//
//  UserDetailModel.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/23/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

// Model used to hold Current Logged In User
// Currently userGrps isn't used, but included for future capabilities

import Foundation

struct UserDetail {
    let userName: String
    let userPrefName: String
    let userMemLvl: String
    let userCarPref: String
    let userGrps: Array<Any>
}
