//
//  AgencydetailsViewController.swift
//  driver
//
//  Created by Apple on 11/12/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit

class AgencydetailsViewController: UIViewController {

    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var phonenumber: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var email: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         let user = try! Rider(from: UserDefaultsConfig.user!)
         let token = UserDefaultsConfig.jwtToken ?? ""
//         
//        getDriver(driverId: user.id ?? 0, token: token) { result in
//             switch result {
//             case .success(let driverDetails):
//                 DispatchQueue.main.async {
//                     self.fullname.text = driverDetails.name
//                     self.phonenumber.text = driverDetails.phone
//                     self.email.text = driverDetails.email
//                     if let imageUrl = URL(string: driverDetails.imageURL) {
//                         self.loadImage(from: imageUrl)
//                     }
//                 }
//                 
//             case .failure(let error):
//                 print("Error: \(error.localizedDescription)")
//             }
//         }
    }
    
    
//    func getDriver(driverId: Int, token: String, completion: @escaping (Result<GetDriverDetails, Error>) -> Void) {
//        // Construct the URL
//        let urlString = "\(Config.Backend)driver/\(driverId)"
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        // Set the Authorization header
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        // Perform the API request
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
//                  let data = data else {
//                print("Invalid response or no data")
//                return
//            }
//            
//            do {
//                let driverDetails = try JSONDecoder().decode(GetDriverDetails.self, from: data)
//                completion(.success(driverDetails))
//            } catch let decodingError {
//                completion(.failure(decodingError))
//            }
//        }
//        task.resume()  // Start the task
//    }

    
 
}
