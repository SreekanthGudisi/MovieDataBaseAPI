//
//  ViewModel.swift
//  DayToDay
//
//  Created by Matrix 1 MBP on 04/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import UIKit
import Foundation

class ViewModel {
    
    // Closure use for notifi
    var reloadList = {() -> () in }
    var errorMessage = {(message : String) -> () in }

    // Array of List Model class
    var resultsArray : [Results] = []{
        // Reload data when data set
        didSet{
            reloadList()
        }
    }
    
    // Get data from API
    public func getMovieDataBaseAPIServiceCall() {
        
        GetMovieDataBaseAPI.instance().getMovieDataBaseAPIServiceDetails { (sussues) in
         
            if sussues == true {
                DispatchQueue.main.async {
                    self.resultsArray = SharedInformation.instance().resultsResponse!
                }
            }
            print(sussues)
        }
    }
}

