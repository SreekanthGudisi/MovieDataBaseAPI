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
    public func getMovieDataBaseAPIServiceDetails(_ register : ResponseModel, completionHandler: @escaping (Bool) -> Void) {
        
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
            
            _ = self.executeAuthenticatedRequest(request: request) { (data, response, error) in
//                guard let data = data, error == nil else {
//                    completionHandler(false)
//                    return
//                }
////                // Using Decoder
////                let decode = JSONDecoder()
////                let response = try decode.decode(ResponseModel.self, from: data)
////                print(response)
//
//                let jsonObject = self.convertToJsonObject(data: data) as? [String : Any]
//                RegisterUser.fromJSON(jsonObject!)
//                RegisterUser.saveResponseToCoreData()
//                completionHandler(true)
                
                if let data = data {
                    do {
                        let jsonDecoder = JSONDecoder()
                        let loadResponseModel = try jsonDecoder.decode(ResponseModel.self, from: data)
                        SaveCoreData.saveResultsResponse(data, loadResponseModel.results!)
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
    
    public func getMovieDataBaseAPIServiceDetails(_ completionHandler: @escaping(ResponseModel?) -> Void) -> URLSessionDataTask {
        
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

        return APIInterface.instance().executeAuthenticatedRequest(request: request, completionHandler: { (data, response, error) in
            if let data = data {
                do {
                    let jsonDecoder = JSONDecoder()
                    let loadResponseModel = try jsonDecoder.decode(ResponseModel.self, from: data)
                    print("loadResponseModel", loadResponseModel)
                    completionHandler(loadResponseModel)
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
                    completionHandler(nil)
                }
            }
        })
    }
    
    // MARK: - APiConfig Reuse methods
    
    public func executeAuthenticatedRequest(request: URLRequest, _ autoErrorHandling: Bool = false, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
        
        var request = request
        //request.setValue(getAuthenticationToken(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return executeRequest(request:request, autoErrorHandling, completionHandler: completionHandler)
    }
    
    public func executeRequest(request: URLRequest, _ autoErrorHandling: Bool = false, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil && autoErrorHandling {
                APIInterface.instance().showError(error: error?.localizedDescription as? Error)
            }
            completionHandler(data, response, error)
        }
        task.resume()
        return task
    }
    
    // SaveCoreData
    class func saveResponseToCoreData(_ data: Data?) {
        //save to core data
        let object: NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Register", into: PersistenceService.context)
        let jsonDecoder = JSONDecoder()
        let loadResponseModel = try? jsonDecoder.decode(Results.self, from: data!)
      //  object?.setValue(RegisterUser.instance().userType, forKey: "userType")
        object?.setValue(loadResponseModel?.original_title, forKey: "original_title")
        object?.setValue(loadResponseModel?.vote_average, forKey: "vote_average")
        object?.setValue(loadResponseModel?.poster_path, forKey: "poster_path")
        PersistenceService.saveContext()
    }
}
