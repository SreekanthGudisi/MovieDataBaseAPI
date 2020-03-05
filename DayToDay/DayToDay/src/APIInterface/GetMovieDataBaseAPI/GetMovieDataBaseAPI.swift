//
//  GetMovieDataBaseAPI.swift
//  DayToDay
//
//  Created by Matrix 1 MBP on 04/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import Foundation

enum APIError: String, Error {
    
    case noNetwork = "No Network"
    case notProperBaseURL = "Not proper base url"
    case serverOverload = "Server is overloaded"
    case permissionDenied = "You don't have permission"
}

//protocol APIServiceProtocol {
//
//    func getMovieDataBaseAPIServiceDetails( complete: @escaping ( _ success: Bool, _ photos: ResponseModel, _ error: APIError? )->() )
//}

class GetMovieDataBaseAPI {

//    func getMovieDataBaseAPIServiceDetails(complete: @escaping (Bool, ResponseModel, APIError?) -> ()) {
//
//        DispatchQueue.global().async {
//            sleep(3)
//            let path = Bundle.main.path(forResource: "content", ofType: "json")!
//            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .iso8601
//            let responseModel = try! decoder.decode(ResponseModel.self, from: data)
//            complete( true, responseModel, nil)
//        }
//    }

    private static var getMovieDataBaseAPI : GetMovieDataBaseAPI? = nil
    static var methodName = "/movie?api_key="
    
    static func instance() -> GetMovieDataBaseAPI {
        
        if (getMovieDataBaseAPI == nil) {
            getMovieDataBaseAPI = GetMovieDataBaseAPI()
        }
        return getMovieDataBaseAPI!
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
}


