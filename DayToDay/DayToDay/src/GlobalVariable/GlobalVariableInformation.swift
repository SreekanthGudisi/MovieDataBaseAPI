//
//  GlobalVariableInformation.swift
//  DayToDay
//
//  Created by Matrix 1 MBP on 04/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import Foundation
import UIKit

struct GlobalVariableInformation {
    
    private static var globalVariableInformation : GlobalVariableInformation? = nil

    // API Key
    var apiKeyString = "a37bdd7b84b703a56a33bbdf2e5ec716" // API Key

    static func instance() -> GlobalVariableInformation {
        if (globalVariableInformation == nil) {
            globalVariableInformation = GlobalVariableInformation()
        }
        return globalVariableInformation!
    }
    
    private init() {
        // Fetch logged in keys
    }
}


