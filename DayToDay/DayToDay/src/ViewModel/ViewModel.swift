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
    func getMovieDataBaseAPIServiceCall() {
        
        _ = GetMovieDataBaseAPI.instance().getMovieDataBaseAPIServiceDetails() { (response) in
            DispatchQueue.main.async {
                guard response == nil else {
                    // step4: do action (like display data on UI, or go to different screen..etc)
                    print(response!)
                    let data = Data()
                    DispatchQueue.main.async {
                        SaveCoreData.saveResultsResponse(data, (response?.results!)!)
                        self.resultsArray = (response?.results!)!
                        SharedInformation.instance().resultsResponse = response?.results
                    }
                    return
                }
            }
        }
    }
}

