//
//  CoreDataManager.swift
//  DayToDay
//
//  Created by Matrix 1 MBP on 10/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    static var coreDataManager : CoreDataManager? = nil
    
    var initialCheckBool : Bool = false
    var vendorNameString = String()
    
    class func instance() -> CoreDataManager {
        if (coreDataManager == nil) {
            coreDataManager = CoreDataManager()
        }
        return coreDataManager!
    }
    
    //MARK: - SavingCoreDataIntoCoreData
    func savingCoreDataIntoCoreData(popularity: Double, voteCount vote_count:Int, videoOfMovie video: Bool, poster_path: Data, id: Int, adult: Bool, backdrop_path: String, language original_language: String, originalTitle original_title: String, average vote_average: Double, overView overview: String, releaseDate release_date: String, Title title: String){
        
            let context = PersistenceService.context
            let entity = NSEntityDescription.entity(forEntityName: "OfflineResults", in: context)
            let newAttributes = NSManagedObject(entity: entity!, insertInto: context)
            
            newAttributes.setValue(popularity, forKey: "popularity")
            newAttributes.setValue(vote_count, forKey: "vote_count")
            newAttributes.setValue(video, forKey: "video")
            newAttributes.setValue(poster_path, forKey: "poster_path")
            newAttributes.setValue(id, forKey: "id")
            newAttributes.setValue(adult, forKey: "adult")
            newAttributes.setValue(backdrop_path, forKey: "backdrop_path")
            newAttributes.setValue(original_language, forKey: "original_language")
            newAttributes.setValue(original_title, forKey: "original_title")
            newAttributes.setValue(title, forKey: "title")
            newAttributes.setValue(vote_average, forKey: "vote_average")
            newAttributes.setValue(overview, forKey: "overview")
            newAttributes.setValue(release_date, forKey: "release_date")
            
            PersistenceService.saveContext()
            do {
            try context.save()

            } catch {
                print("Failed")
            }
    }
}
