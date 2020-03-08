//
//  SaveCoreData.swift
//  DayToDay
//
//  Created by Matrix 1 MBP on 05/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import UIKit
import CoreData

class SaveCoreData {
    
    private static var saveCoreData : SaveCoreData? = nil
    
    class func instance() -> SaveCoreData {
        if (saveCoreData == nil) {
            saveCoreData = SaveCoreData()
        }
        return saveCoreData!
    }

    // SaveCoreData
    class func saveCoreDataModel(_ results: [Results]) {
        //save to core data
        

        
        for result in results {
            let object: NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "OfflineResults", into: PersistenceService.context)

            object?.setValue(result.popularity, forKey: "popularity")
            object?.setValue(result.vote_count, forKey: "vote_count")
            object?.setValue(result.video, forKey: "video")
            
            let imgUrl = "https://image.tmdb.org/t/p/w500" + result.poster_path!
            print("imgUrl", imgUrl)
            let convertTodata: NSData? = imgUrl.data(using: .utf8) as NSData?
            print("convertTodata", convertTodata as Any)
            object?.setValue(convertTodata, forKey: "poster_path")
            
            object?.setValue(result.id, forKey: "id")
            object?.setValue(result.adult, forKey: "adult")
            object?.setValue(result.backdrop_path, forKey: "backdrop_path")
            object?.setValue(result.original_language, forKey: "original_language")
            object?.setValue(result.original_title, forKey: "original_title")
            object?.setValue(result.title, forKey: "title")
            object?.setValue(result.vote_average, forKey: "vote_average")
            object?.setValue(result.overview, forKey: "overview")
            object?.setValue(result.release_date, forKey: "release_date")
            PersistenceService.saveContext()
        }
    }
}
