//
//  SharedInformation.swift
//  DayToDay
//
//  Created by Matrix 1 MBP on 04/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import Foundation

class SharedInformation {
    
    private static var sharedInformation : SharedInformation? = nil
    
    var serachResponse :ResponseModel? = nil
    var resultsResponse : [Results]? = nil
    
    static func instance() -> SharedInformation {
        if (sharedInformation == nil) {
            sharedInformation = SharedInformation()
        }
        return sharedInformation!
    }
    
    private init() {
        // Fetch logged in keys
    }
}
