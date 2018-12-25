//
//  DetailTableViewCell.swift
//  MarketPro
//
//  Created by Andy Alleyne on 12/24/18.
//  Copyright © 2018 AlleyneVentures. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var symbolImage: UIImageView!
    @IBOutlet weak var StockNameOutlet: UILabel!
    @IBOutlet weak var stockDetailLabel: UILabel!
    
    
    @IBOutlet weak var graphViewOutlet: UIView!
    
    @IBAction func button6m(_ sender: UIButton) {
        print("6m button pushed")
    }
    
    @IBAction func button3m(_ sender: UIButton) {
         print("3m button pushed")
    }
    
    
    @IBAction func button12m(_ sender: UIButton) {
         print("12m button pushed")
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }

    
    
    
    
    
    
    
    
    
    
    
}
