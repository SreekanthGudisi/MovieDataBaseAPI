//
//  GetMovieDataBaseAPI.swift
//  DayToDay
//
//  Created by Matrix 1 MBP on 04/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GetMovieDataBaseAPI {

    private static var getMovieDataBaseAPI : GetMovieDataBaseAPI? = nil
    static var methodName = "/movie?api_key="
    
    static func instance() -> GetMovieDataBaseAPI {
        
        if (getMovieDataBaseAPI == nil) {
            getMovieDataBaseAPI = GetMovieDataBaseAPI()
        }
        return getMovieDataBaseAPI!
    }
    
    //MARK:- OTPService
    public func getMovieDataBaseAPIServiceDetails(_ completionHandler: @escaping (Bool) -> Void) {
        
        Reachability.isInternetAvailable(webSiteToPing: nil) { (isInternetAvailable) in
            guard isInternetAvailable else {
                // Internet not available
                completionHandler(false)
                return
            }
            
            // Internet available
            if APIInterface.baseURL.count == 0 {
                APIInterface.instance().showAlert(title: "OOPS", message: "Not getting APIInterface baseURL")
            } else {
                print("Getting baseURL")
            }
            
            if GlobalVariableInformation.instance().apiKeyString.count == 0 {
                APIInterface.instance().showAlert(title: "OOPS", message: "Not getting API Key")
            } else {
                print("Getting API Key")
            }
            let urlBuilder = APIInterface.baseURL + GetMovieDataBaseAPI.methodName + GlobalVariableInformation.instance().apiKeyString
            print(urlBuilder)
            var request = URLRequest(url: URL(string: urlBuilder)!)
            request.httpMethod = "GET"
            
            _ = APIInterface.instance().executeAuthenticatedRequest(request: request) { (data, response, error) in

                if let data = data {
                    do {
                        let jsonDecoder = JSONDecoder()
                        let loadResponseModel = try jsonDecoder.decode(ResponseModel.self, from: data)
                        SaveCoreData.saveCoreDataModel(loadResponseModel.results!)
                        SharedInformation.instance().resultsResponse = loadResponseModel.results
                        completionHandler(true)
                        let httpResponse = response as? HTTPURLResponse
                        if httpResponse!.statusCode.description == "400" {
                            APIInterface.instance().showAlert(title: httpResponse!.statusCode.description, message: "Bad Request")
                        }else if httpResponse!.statusCode.description == "401" {
                            APIInterface.instance().showAlert(title: httpResponse!.statusCode.description, message: "Session got expired please login again")
                        }else if httpResponse!.statusCode.description == "503" {
                            APIInterface.instance().showAlert(title: httpResponse!.statusCode.description, message: "Server is not available")
                        }
                    }
                    catch let error as NSError {
                        APIInterface.instance().showError(error: error.localizedDescription as? Error)
                        completionHandler(false)
                    }
                }

            }
        }
    }
}
