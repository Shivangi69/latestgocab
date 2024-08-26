//
//  TripHistoryCollectionViewCell.swift
//  rider
//
//  Copyright © 2018 minimal. All rights reserved.
//

import UIKit


class PromotionsCollectionViewCell: UICollectionViewCell {
    public var promotion: Promotion?
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textdescription: UILabel!
    @IBOutlet weak var background: UIView!
    
    @IBOutlet weak var couponlable: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        if let pr = promotion {
            title.text = pr.title
            textdescription.text = pr.description
//            if let timestamp = pr.expirationTimestamp {
//                let date = Date(timeIntervalSince1970: timestamp)
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateStyle = .medium // Choose your preferred style
//                dateFormatter.timeStyle = .none   // If you don't want to show time
//                let dateString = dateFormatter.string(from: date)
//                couponlable.text = dateString
//            } else {
//                couponlable.text = "No "
//            }
            let daysLeft = pr.daysLeft
            couponlable.text = "\(daysLeft) Days Left"

            background.dropShadow()
        }
    }
}
