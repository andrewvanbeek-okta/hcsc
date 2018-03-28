//
//  UserDetailModelController.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/23/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

// Initialize Model used to hold Current Logged In User
// Currently userGrps isn't used, but included for future capabilities

import Foundation

class UserDetailModelController {
    
    var userDetail = UserDetail(
        userName: "",
        userPrefName: "",
        userMemLvl: "",
        userCarPref: "",
        userGrps: [""]
    )
}
