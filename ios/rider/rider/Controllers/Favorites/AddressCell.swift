//
//  AddressCell.swift
//  rider
//
//  Copyright © 2018 Minimalistic Apps. All rights reserved.
//

import UIKit


class AddressCell: UICollectionViewCell {
    @IBOutlet weak var textTitle: UILabel!
    var address:Address?
//    @IBOutlet weak var deleteButton: UIButton! // Outlet for the delete button

    weak var delegate:FavoriteAddressDialogDelegate?
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var textAddress: UILabel!
    
    @IBAction func onEditClicked(_ sender: Any) {
        delegate?.update(address: address!)
    }
    override func awakeFromNib() {
            super.awakeFromNib()
//            setupUI()
        }

//    func setupUI() {
//           // Set the cross image for the delete button
////           deleteButton.setImage(UIImage(named: "cross_icon"), for: .normal)
//
//           // Optional: Adjust image content mode or insets if necessary
//           deleteButton.imageView?.contentMode = .scaleAspectFit
//           deleteButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
//       }
    @IBAction func onDeleteClicked(_ sender: Any) {
    
        // Create the confirmation alert
        let confirmationAlert = UIAlertController(
            title: "Delete Address",
            message: "Are you sure you want to delete this address? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        // "OK" action to confirm deletion
        let confirmAction = UIAlertAction(title: "OK", style: .destructive) { _ in
            // Perform the delete action
            if let address = self.address {
                self.delegate?.delete(address: address)
            }
        }
        
        // "Cancel" action to dismiss the alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add actions to the alert
        confirmationAlert.addAction(confirmAction)
        confirmationAlert.addAction(cancelAction)
        
        // Present the alert
        if let viewController = sender as? UIViewController {
            viewController.present(confirmationAlert, animated: true, completion: nil)
        } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(confirmationAlert, animated: true, completion: nil)
        }
    }

    
    
//    @IBAction func onDeleteClicked(_ sender: Any) {
//        // Create the confirmation alert
//        
//    }
   
    
    
    
    
    
    
    
}
protocol FavoriteAddressDialogDelegate: AnyObject {
    func delete(address:Address)
    func update(address:Address)
}
