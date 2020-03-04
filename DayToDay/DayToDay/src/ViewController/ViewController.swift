//
//  ViewController.swift
//  DayToDay
//
//  Created by Matrix 1 MBP on 04/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Class Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Class Varibles
    var viewModel = ViewModel()

    var deafultImage = UIImage(named: "Empty-Image")
    var fetchingMore = false
    var resultsArray = [Results]()
    var filteredData = [Results]()
    var isSeacrhActive = false
    var searchController : UISearchController!
    
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
        
        if section == 0 {
            
            let numberOfRows = ((isSeacrhActive) ? filteredData.count : itemsCount)
            return numberOfRows
        } else if section == 1 && fetchingMore {

            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //pagination: load news items when it requires
     //   checkForLastCell(with: indexPath)
        //setup
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
//            let data = (self.isSeacrhActive) ? self.filteredData[indexPath.row] : viewModel.resultsArray[indexPath.row]
            let results = (self.isSeacrhActive) ? self.filteredData[indexPath.row] : viewModel.resultsArray[indexPath.row]
            cell.movieImage.image = deafultImage
            cell.titleLabel.text = results.original_title
            cell.voteAverageLabel.text = results.vote_average?.description
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        
        let posterPathArray = viewModel.resultsArray[indexPath.row]
        if posterPathArray.poster_path?.count == nil {
            (cell as? TableViewCell)?.movieImage.image = deafultImage
            print(indexPath.row)
            return
        } else {
            print(posterPathArray.poster_path as Any)
            // Checking Cache
            if let dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String]{
                if let path = dict["https://image.tmdb.org/t/p/w500" + (posterPathArray.poster_path!)] {
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                        let img = UIImage(data: data)
                        // If cache is there, Loading into cell from Cache
                        (cell as? TableViewCell)?.movieImage.image = img
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
                        (cell as? TableViewCell)?.movieImage.image = image
                        // StoringImages into Cache
                        StorageImageViewController.storeImage(urlstring: (posterPathArray.poster_path!) as String, img: image)
                    }
                }
            }
            task.resume()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let endScrolling: CGFloat = scrollView.contentOffset.y + scrollView.frame.size.height

        if (endScrolling >= scrollView.contentSize.height) {
            if !fetchingMore {
                fetchNewItems()
            }
        }
        
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//        if offsetY > (contentHeight - scrollView.frame.height) {
//            // fetchMethod
//            if !fetchingMore {
//                fetchNewItems()
//            }
//        }
    }
    
    // Checking Cell
    func fetchNewItems() {
        
        //first Show Indicator
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 1), with: .bottom)
            self.tableView.scrollToRow(at: IndexPath(item: 0, section: 1),
                                       at: .bottom,
                                       animated: true)
        }
        fetchingMore = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.fetchingMore = false
            self.itemsCount += self.OFFSET
            if self.itemsCount > self.viewModel.resultsArray.count {
                self.itemsCount = self.viewModel.resultsArray.count
            }
            self.tableView.reloadData()
        })
    }
}

//MARK:- Functions
extension ViewController {
    
    func initialMethod() {

        // Navigation Title
        navigationItem.title = "Movies"
        
        // Tableview Set Delegate And DataSource
        tableView.delegate = self
        tableView.dataSource = self
        
        // Call XIB
        let loadingNib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.register(loadingNib, forCellReuseIdentifier: "loadingCell")

        // Call pageSetup
        pageSetup()
    }
    
    // Show Activity Indicator
    func showActivityIndicator() {
        
        DispatchQueue.main.async {
            
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    // Hide Activity Indicator
    func hideActivityIndicator() {

        DispatchQueue.main.async {
            
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    // TableViewSetUp
    func tableViewSetup()  {
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    // Initial page settings
    func pageSetup()  {
        
        showActivityIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

            self.tableViewSetup()
            // API calling from ViewModel class
            self.viewModel.getServicecall()
            self.closureSetUp()
            self.hideActivityIndicator()
        }
    }
    
    // Closure initialize
    func closureSetUp()  {
        
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
}

//MARK:- SearchBar
extension ViewController : UISearchBarDelegate, UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        isSeacrhActive = false
        guard searchText.lengthOfBytes(using: String.Encoding.utf8) == 0 else {
            
            filteredData.removeAll()
            filteredData = viewModel.resultsArray.filter({ (user) -> Bool in
                return (user.original_title!.lowercased().contains(searchText.lowercased()))
            })
            isSeacrhActive = true
            tableView!.reloadData()
            return
        }
        //search text is empty, so reload with original orgs
        filteredData.removeAll()
        tableView!.reloadData()
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


