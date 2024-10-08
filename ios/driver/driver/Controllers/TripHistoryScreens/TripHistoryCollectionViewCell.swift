//
//  TripHistoryCollectionViewCell.swift
//  rider
//
//  Copyright © 2018 minimal. All rights reserved.
//

import UIKit


class TripHistoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var finishTimeLabel: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var driverImage: UIImageView!
    
    @IBOutlet weak var carNumber: UILabel!
    @IBOutlet weak var menuicon: UIImageView!
    @IBOutlet weak var tripStatusvalue: UILabel!
    
    @IBAction func GetInvoiceAction(_ sender: Any) {
    }
    @IBOutlet weak var cartype: UILabel!
    @IBOutlet weak var AgencyName: UILabel!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var tripImage: UIImageView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var Amountlbl: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    
    var complainAction: (() -> Void)?
       var deleteAction: (() -> Void)?
       
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        background.layer.borderColor = UIColor.darkGray.cgColor
        
        background.layer.borderWidth = 1
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(menuiconTapped))
                menuicon.isUserInteractionEnabled = true
                menuicon.addGestureRecognizer(tapGesture)
    }
    @objc private func menuiconTapped() {
           showMenu()
       }
       
      private func showMenu() {
           guard let viewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
               return
           }
           
           let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
           
           let complainAction = UIAlertAction(title: "Complain", style: .default) { _ in
               self.complainAction?()
           }
           alertController.addAction(complainAction)
           
           let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
               self.deleteAction?()
           }
           alertController.addAction(deleteAction)
           
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           alertController.addAction(cancelAction)
           
           // Determine the source view controller and view
           let sourceViewController = viewController
           let sourceView = self.menuicon // Replace with your source view or bar button item
           
           if let popoverController = alertController.popoverPresentationController {
               popoverController.sourceView = sourceView
               popoverController.sourceRect = sourceView!.bounds
               popoverController.permittedArrowDirections = .any
               
               sourceViewController.present(alertController, animated: true, completion: nil)
           } else {
               sourceViewController.present(alertController, animated: true, completion: nil)
           }
       }

    
}
