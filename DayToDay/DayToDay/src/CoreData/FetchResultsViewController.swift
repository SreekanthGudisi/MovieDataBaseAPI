//
//  FetchResultsViewController.swift
//  DayToDay
//
//  Created by Matrix 1 MBP on 05/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import UIKit
import CoreData

class FetchResultsViewController: UIViewController {

    
    var resultsArray = [Result]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}

extension FetchResultsViewController {
    
    // Fetch AllData From PersistenceSerivce
    func fetchAllDataFromCoredata() {
        
        let context = PersistenceService.context
        let fetchRequest = NSFetchRequest<Result>(entityName: "NotesData")
        fetchRequest.returnsObjectsAsFaults = true
        resultsArray.removeAll()
        do {
            resultsArray = try context.fetch(fetchRequest)
        } catch {
            print("Unable to fetch from Coredata", error)
        }
//        tableview.reloadData()
    }
}

