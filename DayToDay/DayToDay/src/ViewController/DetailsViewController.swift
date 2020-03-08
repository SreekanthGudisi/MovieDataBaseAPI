//
//  DetailsViewController.swift
//  DayToDay
//
//  Created by Matrix 1 MBP on 07/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var deafultImage = UIImage(named: "Empty-Image")
    var results : Results? = nil
    var offlineResult : OfflineResults? = nil
    private var checkInternet = false
    var newImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        SharedInformation.instance().offlienSearchSelected = true
        self.title = "Details"
        movieImage.image = deafultImage
        tableView.dataSource = self
        if Reachability.isConnectedToNetwork() == true {
            print("Internet is there")
            checkInternet = true
        } else {
            print("Internet is not there")
            checkInternet = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        movieImage.image = newImage
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.reloadData()
    }
}

extension DetailsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }

    private func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if checkInternet == true {
            return 1
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Setup
        if checkInternet == true {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsTableViewCell", for: indexPath) as! DetailsTableViewCell
            cell.titleLabel.text = results?.original_title
            
            let attributsNormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold)]
            let attributsBold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular)]
            
            let durationAttributedString = NSMutableAttributedString(string: "Duration : ", attributes:attributsNormal)
            let durationBoldStringPart = NSMutableAttributedString(string: "I don't know, what I have to show", attributes:attributsBold)
            durationAttributedString.append(durationBoldStringPart)
            cell.durationLabel.attributedText = durationAttributedString
            
            let releaseDateAttributedString = NSMutableAttributedString(string: "Release Date : ", attributes:attributsNormal)
            let releaseDateBoldStringPart = NSMutableAttributedString(string: (results?.release_date!.description)!, attributes:attributsBold)
            releaseDateAttributedString.append(releaseDateBoldStringPart)
            cell.releaseDateLabel.attributedText = releaseDateAttributedString
            
            let languagesAttributedString = NSMutableAttributedString(string: "Languages : ", attributes:attributsNormal)
            let languagesBoldStringPart = NSMutableAttributedString(string: (results?.original_language!.description)!, attributes:attributsBold)
            languagesAttributedString.append(languagesBoldStringPart)
            cell.languagesLabel.attributedText = languagesAttributedString
            
            let genresAttributedString = NSMutableAttributedString(string: "Genres : ", attributes:attributsNormal)
            let genresBoldStringPart = NSMutableAttributedString(string:  "I don't know, what I have to show", attributes:attributsBold)
            genresAttributedString.append(genresBoldStringPart)
            cell.genersLabel.attributedText = genresAttributedString
            
            let ratingAttributedString = NSMutableAttributedString(string: "Rating : ", attributes:attributsNormal)
            let ratingsBoldStringPart = NSMutableAttributedString(string: (results?.vote_average!.description)! + " & " + ((results?.vote_count!.description)!), attributes:attributsBold)
            ratingAttributedString.append(ratingsBoldStringPart)
            cell.ratingLabel.attributedText = ratingAttributedString

            cell.aboutLabel.text = results?.overview?.description
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsTableViewCell", for: indexPath) as! DetailsTableViewCell
            cell.titleLabel.text = offlineResult?.original_title
            
            let attributsNormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold)]
            let attributsBold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular)]
            
            let durationAttributedString = NSMutableAttributedString(string: "Duration : ", attributes:attributsNormal)
            let durationBoldStringPart = NSMutableAttributedString(string: "I don't know, what I have to show", attributes:attributsBold)
            durationAttributedString.append(durationBoldStringPart)
            cell.durationLabel.attributedText = durationAttributedString
            
            let releaseDateAttributedString = NSMutableAttributedString(string: "Release Date : ", attributes:attributsNormal)
            let releaseDateBoldStringPart = NSMutableAttributedString(string: (offlineResult?.release_date)!, attributes:attributsBold)
            releaseDateAttributedString.append(releaseDateBoldStringPart)
            cell.releaseDateLabel.attributedText = releaseDateAttributedString
            
            let languagesAttributedString = NSMutableAttributedString(string: "Languages : ", attributes:attributsNormal)
            let languagesBoldStringPart = NSMutableAttributedString(string: (offlineResult?.original_language!.description)!, attributes:attributsBold)
            languagesAttributedString.append(languagesBoldStringPart)
            cell.languagesLabel.attributedText = languagesAttributedString
            
            let genresAttributedString = NSMutableAttributedString(string: "Genres : ", attributes:attributsNormal)
            let genresBoldStringPart = NSMutableAttributedString(string:  "I don't know, what I have to show", attributes:attributsBold)
            genresAttributedString.append(genresBoldStringPart)
            cell.genersLabel.attributedText = genresAttributedString
            
            let ratingAttributedString = NSMutableAttributedString(string: "Rating : ", attributes:attributsNormal)
            let ratingsBoldStringPart = NSMutableAttributedString(string: (offlineResult?.vote_average.description)! + " & " + ((offlineResult?.vote_count.description)!), attributes:attributsBold)
            ratingAttributedString.append(ratingsBoldStringPart)
            cell.ratingLabel.attributedText = ratingAttributedString

            cell.aboutLabel.text = offlineResult?.overview?.description
            return cell
        }
    }
}
