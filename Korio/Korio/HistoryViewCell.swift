//
//  HistoryViewCell.swift
//  Korio
//
//  Created by Student on 2018-03-01.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit

class HistoryViewCell: UITableViewCell {
    
    @IBOutlet weak var packageImage: UILabel?
    @IBOutlet weak var packageName: UILabel?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
