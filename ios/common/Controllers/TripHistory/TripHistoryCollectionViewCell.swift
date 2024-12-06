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
  
    @IBOutlet weak var cartype: UILabel!
    @IBOutlet weak var AgencyName: UILabel!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var tripImage: UIImageView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var Amountlbl: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    var complainAction: (() -> Void)?
    var deleteAction: (() -> Void)?
       
    @IBAction func GetInvoiceAction(_ sender: Any) {
         
     
        
        
        
    }
    
    
    func getPreferredAgency(riderId: Int, token: String, completion: @escaping (Result<[PreferredAgency], Error>) -> Void) {
        // Construct the URL
        let urlString = Config.Backend  + "trips/invoice/" + "\(riderId)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Set the Authorization header
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Perform the API request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check response and data
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                print("Invalid response or no data")
                return
            }
            
            
            
            do {
                let preferredAgencyResponse = try JSONDecoder().decode(PreferredAgencyResponse.self, from: data)
                completion(.success(preferredAgencyResponse.data.preferredAgencies))
                
                
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }
        
        task.resume()  // Start the task
    }
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
           
          
          
          let hideAction = UIAlertAction(title: "Hide", style: .destructive) { _ in
                // Show confirmation alert
                let confirmationAlert = UIAlertController(
                    title: "Message",
                    message: "Are you sure you want to hide travel? This action is not reversible; however, the travel info is still available for the operator.",
                    preferredStyle: .alert
                )
                
                let confirmAction = UIAlertAction(title: "OK", style: .destructive) { _ in
                    // Call delete function
                    self.deleteAction?()
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                confirmationAlert.addAction(cancelAction)
                confirmationAlert.addAction(confirmAction)
                
                viewController.present(confirmationAlert, animated: true, completion: nil)
            }
            alertController.addAction(hideAction)
            
          
           let complainAction = UIAlertAction(title: "Complain", style: .default) { _ in
               self.complainAction?()
           }
           alertController.addAction(complainAction)
           
//           let deleteAction = UIAlertAction(title: "Hide", style: .destructive) { _ in
//               
//               self.deleteAction?()
//           }
//           alertController.addAction(deleteAction)
           
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
