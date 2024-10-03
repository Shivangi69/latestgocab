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
    }
    override var isSelected: Bool {
        didSet {
            self.contentView.alpha = isSelected ? 1 : 0.5
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
     
        // Configure the view for the selected state
    }
    
    func initialize(service:Service, distance: Int, duration: Int, currency: String) {
        self.service = service
        self.distance = Double(distance)
        self.duration = Double(duration)
        self.currency = currency
//        self.updatePrice()
        textTitle.text = service.title
//        actualcost.text = service.baseFare != nil ? "\(service.baseFare!)" : nil
//        discountcost.text = service.cost != nil ? "\(service.cost!)" : nil
//        
        
        actualcost.text = service.baseFare != nil ? "\(service.baseFare!)" : ""
    discountcost.text = service.cost != nil ? "\(service.cost!)" : ""
        pplcount.text = String(service.maxQuantity)
        

//        imageIcon.image = service.media
        if let media = service.media, let address = media.address {
            let url = URL(string: Config.Backend + address)
            imageIcon.kf.setImage(with: url)
        }

    }
}
