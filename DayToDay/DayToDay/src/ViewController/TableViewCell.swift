//
//  TableViewCell.swift
//  DayToDay
//
//  Created by Matrix 1 MBP on 04/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var voteAverageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
