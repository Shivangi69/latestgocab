//
//  TripHistoryCollectionViewCell.swift
//  rider
//
//  Copyright © 2018 minimal. All rights reserved.
//

import UIKit
import MobileCoreServices
import SPAlert

class TripHistoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var finishTimeLabel: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var carNumber: UILabel!
    @IBOutlet weak var menuicon: UIImageView!
    @IBOutlet weak var tripStatusvalue: UIButton!
    @IBOutlet weak var cartype: UILabel!
    @IBOutlet weak var AgencyName: UILabel!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var tripImage: UIImageView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var Amountlbl: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    var complainAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    let user = try! Rider(from: UserDefaultsConfig.user!)
    let token = UserDefaultsConfig.jwtToken ?? ""
    @IBAction func GetInvoiceAction(_ sender: Any) {
        let tripId = 12345 // Replace with the actual trip ID you want to download the invoice for
        let token = token // Replace with the actual token

        downloadInvoice(tripId: tripId, token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("Invoice saved at: \(data)")
//                    self.showAlert(title: "Download Successful", message: "Your invoice has been saved successfully.")
                    SPAlert.present(title: NSLocalizedString(NSLocalizedString("Download Successfully", comment: ""), comment: ""), preset: .like)
                case .failure(let error):
                    // Handle error
                    print("Failed to download invoice: \(error.localizedDescription)")
                    SPAlert.present(title: NSLocalizedString(NSLocalizedString("Unable to Download", comment: ""), comment: ""), preset: .dislike)
                }
            }
        }
    }

    
//    @IBAction func feedbackButtonTapped(_ sender: UIButton) {
//        // Initialize the feedback view controller
//        let feedbackVC = FeedbackPopupViewController()
//
//        // Set the modal presentation style to 'overCurrentContext' for a pop-up style
//        feedbackVC.modalPresentationStyle = .overCurrentContext
//        feedbackVC.modalTransitionStyle = .crossDissolve
//
//        // Present the feedback view controller modally
//        present(feedbackVC, animated: true, completion: nil)
//    }



//    @objc private func cancelTapped() {
//        dismiss(animated: true, completion: nil)
//    }

    func createCustomDirectory() -> URL? {
        
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to access documents directory")
            return nil
        }
        
        let customDirectoryURL = documentsURL.appendingPathComponent("Invoices")
        if !fileManager.fileExists(atPath: customDirectoryURL.path) {
            do {
                try fileManager.createDirectory(at: customDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                print("Custom directory created at: \(customDirectoryURL)")
            } catch {
                print("Failed to create custom directory: \(error.localizedDescription)")
                return nil
            }
            
        }
        return customDirectoryURL
    }

    
    // Function to save PDF to the custom directory
        func savePDFToCustomDirectory(data: Data, filename: String) -> URL? {
            guard let directoryURL = createCustomDirectory() else { return nil }
            
            let fileURL = directoryURL.appendingPathComponent(filename)
            do {
                try data.write(to: fileURL)
                print("PDF saved successfully at: \(fileURL)")
                return fileURL
            } catch {
                print("Failed to save PDF: \(error.localizedDescription)")
                return nil
            }
        }

    func downloadInvoice(tripId: Int, token: String, completion: @escaping (Result<URL, Error>) -> Void) {
        // Construct the URL for the API endpoint using the tripId
        let urlString = Config.Backend + "trips/invoice/\(1306)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Set the Authorization header with the token
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Perform the network request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                completion(.failure(error))
                return
            }

            // Check for valid response, status code, and content type
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let mimeType = httpResponse.mimeType, mimeType == "application/pdf",
                  let data = data else {
                print("Invalid response or data is not a PDF")
                return
            }
            
            // Define the folder path where you want to save the PDF
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let folderPath = documentsDirectory.appendingPathComponent("Invoices")
            
            // Create the folder if it doesn't exist
            if !fileManager.fileExists(atPath: folderPath.path) {
                do {
                    try fileManager.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error creating folder: \(error)")
                    completion(.failure(error))
                    return
                }
            }

            // Define the file path for the PDF
            let fileURL = folderPath.appendingPathComponent("invoice_\(tripId).pdf")
            
            // Save the PDF data to the file
            do {
                try data.write(to: fileURL)
                print("PDF saved successfully at: \(fileURL.path)")
                completion(.success(fileURL))
            } catch {
                print("Error saving PDF: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()  // Start the task
    }
    
    
    
// func downloadInvoice(tripId: Int, token: String, completion: @escaping (Result<Data, Error>) -> Void) {
//    // Construct the URL for the API endpoint using the tripId
//    let urlString = Config.Backend + "trips/invoice/\(1306)"
//    guard let url = URL(string: urlString) else {
//        print("Invalid URL")
//        return
//    }
//
//    var request = URLRequest(url: url)
//    request.httpMethod = "GET"
//    
//    // Set the Authorization header with the token
//    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//    // Perform the network request
//    let task = URLSession.shared.dataTask(with: request) { data, response, error in
//        // Handle network error
//        if let error = error {
//            completion(.failure(error))
//            return
//        }
//
//        // Check for valid response, status code, and content type
//        guard let httpResponse = response as? HTTPURLResponse,
//              httpResponse.statusCode == 200,
//              let mimeType = httpResponse.mimeType, mimeType == "application/pdf",
//              let data = data else {
//            print("Invalid response or data is not a PDF")
//            return
//        }
//        
//        // Return the downloaded file data in the completion block
//        completion(.success(data))
//    }
//    
//    task.resume()  // Start the task
//}

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
    
    
    
//    if travel.status?.rawValue ?? "" == "Pending Review" {
//
//        let vc = FavoriteAddressDialogViewController(nibName: "FavoriteAddressDialogViewController", bundle: nil)
//        vc.preferredContentSize = CGSize(width: 1000,height: 400)
//        let dialog = UIAlertController(title: NSLocalizedString("Favorite Address", comment: "Favorites Add Dialog Title"), message: "", preferredStyle: .alert)
//        dialog.setValue(vc, forKey: "contentViewController")
//        dialog.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default) { action in
//            if let title = vc.textTitle.text, title.isEmpty {
//                SPAlert.present(title: NSLocalizedString("Title is required", comment: ""), preset: .exclamation)
//                return
//            }
//            let address = Address()
//            address.title = vc.textTitle.text
//            address.address = vc.textAddress.text
//            address.location = vc.map.camera.centerCoordinate
//            UpsertAddress(address: address).execute() { result in
//                switch result {
//                case .success(_):
//                    self.refreshList(self)
//                    
//                case .failure(let error):
//                    error.showAlert()
//                }
//            }
//        })
//        dialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        self.present(dialog, animated: true)
//    }
    
    
    
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


