//
//  BTTableViewCell.swift
//  rider
//
//  Created by Rohit wadhwa on 27/09/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit

class BTTableViewCell: UITableViewCell {
    @IBOutlet weak var discountcost: UILabel!
    @IBOutlet weak var actualcost: UILabel!

    @IBOutlet weak var pplcount: UILabel!

    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var textTitle: UILabel!
    @IBOutlet weak var textCost: UILabel!
    @IBOutlet weak var buttonMinus: UIButton!
    @IBOutlet weak var buttonPlus: UIButton!
    private var service: Service!
    private var quantity: Int = 0
    private var distance: Double = 0
    private var duration: Double = 0
    private var currency: String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.contentView.backgroundColor = .yellow
        
    }
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? UIColor(named: "ThemeYellow") : UIColor.clear

        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
             // Ensure that the color change happens during selection
             self.contentView.backgroundColor = selected ? UIColor(named: "ThemeYellow") : UIColor.white
    }
    
    
    
    
    func initialize(service:Service, distance: Int, duration: Int, currency: String) {
        self.service = service
        self.distance = Double(distance)
        self.duration = Double(duration)
        self.currency = currency
        



//        self.updatePrice()
        textTitle.text = service.title

        pplcount.text = service.seatingCapacity != nil ? "₹\(service.seatingCapacity!)" : ""
        actualcost.text = service.baseFare != nil ? "₹ \(service.baseFare!)" : ""
        
        
//        discountcost.text = String(service.seatingCapacity)


//        imageIcon.image = service.media
        if let media = service.media, let address = media.address {
            let url = URL(string: Config.Backend + address)
            imageIcon.kf.setImage(with: url)
        }

    }
}
