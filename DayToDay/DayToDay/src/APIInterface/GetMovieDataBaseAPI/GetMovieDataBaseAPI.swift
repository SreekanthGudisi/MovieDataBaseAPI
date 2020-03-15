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
    var resultsArray = [Results]()
    var offilineArray = [OfflineResults]()
    
    static func instance() -> GetMovieDataBaseAPI {
        
        if (getMovieDataBaseAPI == nil) {
            getMovieDataBaseAPI = GetMovieDataBaseAPI()
        }
        return getMovieDataBaseAPI!
    }

    //MARK:- GET API 
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
                        SharedInformation.instance().resultsResponse = loadResponseModel.results
                        
                        // Saving Response Into CoreData
                        for details in SharedInformation.instance().resultsResponse! {
                            
                            let posterPath : String = "https://image.tmdb.org/t/p/w500" + details.poster_path!
                            let urlString : URL = URL(string: posterPath)!
                            print(urlString as Any)
                            //create the session object
                            let task = URLSession.shared.dataTask(with: urlString) { (posterPathData, respose, error) in
                                DispatchQueue.main.async {
                                    
                                    CoreDataManager.instance().savingCoreDataIntoCoreData(popularity: details.popularity!, voteCount: details.vote_count!, videoOfMovie: details.video!, poster_path: posterPathData!, id: details.id!, adult: details.adult!, backdrop_path: details.backdrop_path!, language: details.original_language!, originalTitle: details.original_title!, average: details.vote_average!, overView: details.overview!, releaseDate: details.release_date!, Title: details.title!)
                                }
                            }
                            task.resume()
                        }
                        
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
