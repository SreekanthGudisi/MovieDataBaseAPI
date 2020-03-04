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
    
    let date = Date()
    let formatter = DateFormatter()

//    ///Array List of Model class
//    var serviceResponse : ResponseModel? {
//        ///Reload data when data set
//        didSet{
//            reloadList()
//        }
//    }

    // Array of List Model class
    var resultsArray : [Results] = []{
        // Reload data when data set
        didSet{
            reloadList()
        }
    }
    
    // Get data from API
    func getServicecall() {
        
        let urlString: String = "https://api.themoviedb.org/3/discover/movie?api_key=\(GlobalVariableInformation.instance().apiKeyString)"
        print(urlString)
        let encodedUrl = urlString.encodedUrl()
        print(encodedUrl as Any)
        // Create the Request with URLRequest
        var request = URLRequest(url: encodedUrl!)
        request.httpMethod = "GET"
        // Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("authorization", forHTTPHeaderField: "x-api-key")
        //create the session object
        let session = URLSession.shared
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            // Error
            if let error = error {
                print("error:", error)
                return
            }
            // Response Status with HTTPURLResponse
            let responseStatus = response as? HTTPURLResponse
            print("responseStatus Code", responseStatus as Any)
            do {
                guard let data = data else {
                    return
                }
                // Using Decoder
                let decode = JSONDecoder()
                let response = try decode.decode(ResponseModel.self, from: data)
                print(response)
                //self.resultsArray.removeAll()
                DispatchQueue.main.async {
                    self.resultsArray = response.results!
                    SharedInformation.instance().resultsResponse = response.results
                }
            } catch {
                print("Error ->\(error.localizedDescription)")
                self.errorMessage(error.localizedDescription)
            }
        })
        task.resume()
    }
}

