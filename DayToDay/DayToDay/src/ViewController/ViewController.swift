//
//  ViewController.swift
//  DayToDay
//
//  Created by Matrix 1 MBP on 04/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // Class Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Class Varibles
    private var viewModel = ViewModel()
    private var deafultImage = UIImage(named: "Empty-Image")
    private var fetchingMore = false
    private var resultsArray = [Results]()
    private var filteredData = [Results]()
    private var isSeacrhActive = false
    private var searchController : UISearchController!
    private var offlineResultsStroreArray = [OfflineResults]()
    private var offlineResultsArray = [OfflineResults]()
    private var offlineResultsfilteredData = [OfflineResults]()
    private var checkInternet = false
    var selectedImageOrDocumentURLData = Data()
    
    private var OFFSET = 7
    private var itemsCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call Initial Method
        initialMethod()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if Reachability.isConnectedToNetwork() == true {
            print("Internet is there")
            checkInternet = true
        } else {
            print("Internet is not there")
            checkInternet = false
            if SharedInformation.instance().offlienSearchSelected == false {
                fetchNewItems()
            }
        }
    }
}

// TableView
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }

    private func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if checkInternet == true {
            if section == 0 {
                
                let numberOfRows = ((isSeacrhActive) ? filteredData.count : itemsCount)
                return numberOfRows
            } else if section == 1 && fetchingMore {

                return 1
            }
            return 0
        }else {
            if section == 0 {
                
                let numberOfRows = ((isSeacrhActive) ? offlineResultsfilteredData.count : itemsCount)
                return numberOfRows
            } else if section == 1 && fetchingMore {

                return 1
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //setup
        if checkInternet == true {
            
            if indexPath.section == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
                let results = (self.isSeacrhActive) ? self.filteredData[indexPath.row] : resultsArray[indexPath.row]
                print("results", results)
                cell.movieImage.image = deafultImage
                cell.titleLabel.text = results.original_title
                cell.voteAverageLabel.text = results.vote_average?.description
                return cell
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
                cell.spinner.startAnimating()
                return cell
            }
        } else {
            
            if indexPath.section == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
                let results = (self.isSeacrhActive) ? self.offlineResultsfilteredData[indexPath.row] : offlineResultsArray[indexPath.row]
                print("results", results)
                cell.movieImage.image = deafultImage
                cell.titleLabel.text = results.original_title
                cell.voteAverageLabel.text = results.vote_average.description
                return cell
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
                cell.spinner.startAnimating()
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if cell.isKind(of: LoadingCell.self) {
            return
        }
        
        let existingCell = cell as! TableViewCell
        
        if checkInternet == true {
            
            let posterPathArray = resultsArray[indexPath.row]
            if posterPathArray.poster_path?.count == nil {
                existingCell.movieImage.image = deafultImage
                print(indexPath.row)
                return
            } else {
                // Checking Cache
                if let dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String]{
                    if let path = dict["https://image.tmdb.org/t/p/w500" + (posterPathArray.poster_path!)] {
                        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                            let img = UIImage(data: data)
                            // If cache is there, Loading into cell from Cache
                            existingCell.movieImage.image = img
                            return
                        }
                    }
                }
                //lazy loading
                let session = URLSession.shared
                let imageURL = URL(string: "https://image.tmdb.org/t/p/w500" + (posterPathArray.poster_path!))
                let task = session.dataTask(with: imageURL!) { (data, response, error) in
                    guard error == nil else {
                        return
                    }
                    DispatchQueue.main.async {
                        NSLog("cell number \(indexPath.row)")
                        if let image = UIImage(data: data!) {
                            // calling from API
                            existingCell.movieImage.image = image
                            // StoringImages into Cache
                            StorageImageViewController.storeImage(urlstring: (posterPathArray.poster_path!) as String, img: image)
                        }
                    }
                }
                task.resume()
            }
        } else {
            
            if offlineResultsArray.count == 0 {
                APIInterface.instance().showAlert(title: "OOPS", message: "Seems to be offline storage is empty. Please run it on with internet and try again")
            } else {
                let results = offlineResultsArray[indexPath.row]
                existingCell.movieImage.clipsToBounds = true
                existingCell.movieImage.layer.cornerRadius = 10
                if results.poster_path == nil {
                    existingCell.movieImage.image = deafultImage
                } else{
                    let imageData = results.poster_path!
                    let coredataLoadedimage = UIImage(data: imageData)
                    existingCell.movieImage.image = coredataLoadedimage
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        let cell = tableView.cellForRow(at: indexPath!) as! TableViewCell

        if checkInternet == true {
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController
            vc!.results = self.isSeacrhActive ? self.filteredData[indexPath!.row] : self.resultsArray[indexPath!.row]
            vc?.newImage = cell.movieImage.image
            navigationController?.pushViewController(vc!, animated: true)
        } else {
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController
            vc!.offlineResult = self.isSeacrhActive ? self.offlineResultsfilteredData[indexPath!.row] : self.offlineResultsArray[indexPath!.row]
            vc?.newImage = cell.movieImage.image
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
}

//MARK:- UISearchDelegate
extension ViewController {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let endScrolling: CGFloat = scrollView.contentOffset.y + scrollView.frame.size.height

        if (endScrolling >= scrollView.contentSize.height) {
            if !fetchingMore {
                fetchNewItems()
            }
        }
    }
}

//MARK:- Functions
extension ViewController {
    
    private func initialMethod() {

        // Navigation Title
        navigationItem.title = "Movies"
        
        // Call XIB
        let loadingNib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.register(loadingNib, forCellReuseIdentifier: "loadingCell")

        // Call pageSetup
        pageSetup()
    }
    
    // Show Activity Indicator
    private func showActivityIndicator() {
        
        DispatchQueue.main.async {
            
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    // Hide Activity Indicator
    private func hideActivityIndicator() {

        DispatchQueue.main.async {
            
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    // TableViewSetUp
    private func tableViewSetup()  {
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    // Initial page settings
    private func pageSetup()  {
        
        showActivityIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

            self.tableViewSetup()
            // API calling from ViewModel class
            self.viewModel.getMovieDataBaseAPIServiceCall()
            self.closureSetUp()
            self.hideActivityIndicator()
        }
    }
    
    // Closure initialize
    private func closureSetUp()  {
        
        showActivityIndicator()
        viewModel.reloadList = { [weak self] ()  in
            // UI changes in main tread
            DispatchQueue.main.async {
                self?.fetchNewItems()
                self?.hideActivityIndicator()
            }
        }
        viewModel.errorMessage = { [weak self] (message)  in
            DispatchQueue.main.async {
                print(message)
                self?.hideActivityIndicator()
            }
        }
    }
    
    // Checking Cell
    private func fetchNewItems() {
        
        //first Show Indicator
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 1), with: .bottom)
            self.tableView.scrollToRow(at: IndexPath(item: 0, section: 1),
                                       at: .bottom,
                                       animated: true)
        }
        
        if checkInternet == true {
            resultsArray = viewModel.resultsArray
            fetchingMore = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
                self.fetchingMore = false
                self.itemsCount += self.OFFSET
                if self.itemsCount > self.resultsArray.count {
                    self.itemsCount = self.resultsArray.count
                }
                self.tableView.reloadData()
            })
            
        }else {
            fetchingMore = true
            fetchAllDataFromCoredata()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
                self.fetchingMore = false
                self.itemsCount += self.OFFSET
                if self.itemsCount > self.offlineResultsArray.count {
                    self.itemsCount = self.offlineResultsArray.count
                }
                self.tableView.reloadData()
            })
        }
    }
}

//MARK:- SearchBar
extension ViewController : UISearchBarDelegate, UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        isSeacrhActive = false
        if checkInternet == true {
            
            guard searchText.lengthOfBytes(using: String.Encoding.utf8) == 0 else {
                
                filteredData.removeAll()
                filteredData = resultsArray.filter({ (movie) -> Bool in
                    return (movie.original_title!.lowercased().contains(searchText.lowercased()))
                })
                isSeacrhActive = true
                tableView!.reloadData()
                return
            }
            //search text is empty, so reload with original orgs
            filteredData.removeAll()
            tableView!.reloadData()
        } else {
            
            guard searchText.lengthOfBytes(using: String.Encoding.utf8) == 0 else {
                
                offlineResultsfilteredData.removeAll()
                offlineResultsfilteredData = offlineResultsArray.filter({ (movie) -> Bool in
                    return (movie.original_title!.lowercased().contains(searchText.lowercased()))
                })
                isSeacrhActive = true
                tableView!.reloadData()
                return
            }
            //search text is empty, so reload with original orgs
            filteredData.removeAll()
            tableView!.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //do something
        if searchBar.text?.count == 0 {
            searchBar.resignFirstResponder() //hide keyboard
        }else {
            searchBar.resignFirstResponder()
            searchBar.text = ""
            isSeacrhActive = false
            filteredData.removeAll()
            tableView!.reloadData()
        }
    }
}

//MARK:- Fetch CoreData From PersistenceSerivce
extension ViewController {
    
    private func fetchAllDataFromCoredata() {
        
        let context = PersistenceService.context
        let fetchRequest = NSFetchRequest<OfflineResults>(entityName: "OfflineResults")
        fetchRequest.returnsObjectsAsFaults = true
        offlineResultsArray.removeAll()
        do {
            offlineResultsArray = try context.fetch(fetchRequest)
            print(offlineResultsArray)
        } catch {
            print("Unable to fetch from Coredata", error)
        }
        self.tableView.reloadData()
    }
}

