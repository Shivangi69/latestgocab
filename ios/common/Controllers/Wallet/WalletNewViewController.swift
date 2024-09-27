//
//  WalletNewViewController.swift
//  rider
//
//  Created by Admin on 25/09/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit
import MaterialComponents

class WalletNewViewController: UIViewController {

    @IBOutlet weak var frommmm: UILabel!
    @IBOutlet weak var Toooooooo: UILabel!
    @IBOutlet weak var amunttext: MDCOutlinedTextField!
    @IBOutlet weak var taxiname: UILabel!
    @IBOutlet weak var taxidetial: UILabel!
    @IBOutlet weak var drivername: UILabel!
    @IBOutlet weak var driverimage: UIImageView!
    var amount: Double?
    var currency: String?
    
    var taxinameStr: String?
    var taxidetialStr: String?
    var drivernamestr: String?
    var driverimageStr: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        amunttext.text = String()
        requestRefresh()
        fetchData()
       
        let stringValue = "\(amount ?? 0.0)"
        print(stringValue)
        amunttext.text = stringValue
        // Do any additional setup after loading the view.
        frommmm.text = UserDefaults.standard.string(forKey: "LOCA")
//        ToAdd = Request.shared.addresses[1]
        Toooooooo.text = UserDefaults.standard.string(forKey: "LOCB")
    }
    
    @objc private func requestRefresh() {
        GetCurrentRequestInfo().execute() { result in
            switch result {
            case .success(let response):
                print(response)
                Request.shared = response.request
              //  self.refreshScreen(driverLocation: response.driverLocation)
                
            case .failure(_):
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    func fetchData() {
        // API endpoint URL
        let id = Request.shared.driver?.id
        var str  = String()
        str = "\(id ?? 0)"
        let url = URL(string: Config.Backend + "driver/" + str)!

        // Create URLRequest with the URL
        var request = URLRequest(url: url)
        
        // Add Bearer token to the request header
        let token = UserDefaultsConfig.jwtToken
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        
        // Create URLSession
        let session = URLSession.shared
        
        // Create data task to fetch data from the API
        let task = session.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // Check if there's a response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No HTTP response")
                return
            }
            
            // Check the status code
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP Error: \(httpResponse.statusCode)")
                return
            }
            
            // Check if data is received
            guard let data = data else {
                print("No data received")
                return
            }

            do {
                // Parse JSON data into a dictionary
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let data = jsonObject["data"] as? [String: Any],
                   let driver = data["driver"] as? [String: Any],
                   let assignedVehicle = driver["assignedVehicle"] as? [String: Any],
                   let agency = driver["agency"] as? [String: Any],
                    let driverMedia = driver["driverMedia"] as? [[String: Any]] {

                
                    print("No data received",data)

                    // Extract car details
                    let licensePlateNumber = assignedVehicle["license_plate_number"] as? String ?? "N/A"
                    let make = assignedVehicle["make"] as? String ?? "N/A"
                    let model = assignedVehicle["model"] as? String ?? "N/A"
                    let color = assignedVehicle["color"] as? String ?? "N/A"
                    let vehicleType = assignedVehicle["vehicle_type"] as? String ?? "N/A"
                    let notes = assignedVehicle["notes"] as? String ?? "N/A"
                    let agencyName = agency["agency_name"] as? String ?? "N/A"
                    let agencyyear = agency["registration_year"] as? String ?? "N/A"
                    let agencaddress = agency["address"] as? String ?? "N/A"
                    let fullname = agency["fullname"] as? String ?? "N/A"
                    let phone = agency["phone"] as? String ?? "N/A"
                    let email = agency["email"] as? String ?? "N/A"
                    let logo_url = agency["logo_url"] as? String ?? "N/A"

                    // Print car details
                    print("License Plate Number: \(licensePlateNumber)")
                    print("Make: \(make)")
                    print("Model: \(model)")
                    print("Color: \(color)")
                    print("Vehicle Type: \(vehicleType)")
                    print("Notes: \(notes)")
                    print("Agency Name: \(agencyName)")
                    print("Agency add: \(agencyName)")

                    // Update UI on the main thread
                    DispatchQueue.main.async {
                        self.taxiname.text = make + " " + color + " " + model + " " + vehicleType + " " + licensePlateNumber
                        //self.AGencyName.text = agencyName
                        
                       // self.AgencyNameText.text = agencyName
                       // self.Agency_Year.text = agencyName + " (" + agencyyear  + ")"
                        self.taxidetial.text = agencaddress
                        self.drivername.text = fullname
//                        self.emai_text.text = email
//                        self.phone_number.text = phone
                        
                        
                        let profileMediaUrl = driverMedia.first { $0["mediaType"] as? String == "profile" }?["url"] as? String ?? ""
                                        let fullProfileUrl = Config.Backend + logo_url
                                        
                        let fullProfileUrl1 = Config.Backend + profileMediaUrl

//                        self.driverimage.layer.cornerRadius = 50
//                        self.driverimage.layer.masksToBounds = true
                        self.driverimage.layer.cornerRadius = 40
                        self.driverimage.layer.masksToBounds = true
//                        if let encodedProfileUrl = fullProfileUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
//                                                if let mediaUrl = URL(string: encodedProfileUrl) {
//                                                    self.driverimage.kf.setImage(with: mediaUrl, placeholder: UIImage(named: "profile"))
//                                                } else {
//                                                    print("Invalid mediaUrl: \(encodedProfileUrl)")
//                                                }
//                                            }
                        if let encodedProfileUrl = fullProfileUrl1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                                                if let mediaUrl = URL(string: encodedProfileUrl) {
                                                    self.driverimage.kf.setImage(with: mediaUrl, placeholder: UIImage(named: "Nobody"))
                                                } else {
                                                    print("Invalid mediaUrl: \(encodedProfileUrl)")
                                                }
                                            }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Start the data task
        task.resume()
    }
    
    
    
//    func DoPayment() {
//        // API endpoint URL
//        let id = Request.shared.rider?.id
//        var str  = String()
//        str = "\(id ?? 0)"
//
//        let paymentRequest = [
//            "amount": amount ?? 0.0,
//               "productDescription": "productDescription",
//            "tripId": id ?? 0
//           ] as [String : Any]
//
//        let url = URL(string: Config.Backend + "payment/mmg/payment-link")!
//
//        // Create URLRequest with the URL
//        var request = URLRequest(url: url)
//
//        // Add Bearer token to the request header
//        let token = UserDefaultsConfig.jwtToken
//        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
//
//        // Create URLSession
//        let session = URLSession.shared
//
//        // Create data task to fetch data from the API
//        let task = session.dataTask(with: request) { data, response, error in
//            // Check for errors
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//
//            // Check if there's a response
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("No HTTP response")
//                return
//            }
//
//            // Check the status code
//            guard (200...299).contains(httpResponse.statusCode) else {
//                print("HTTP Error: \(httpResponse.statusCode)")
//                return
//            }
//
//            // Check if data is received
//            guard let data = data else {
//                print("No data received")
//                return
//            }
//
//            do {
//                // Parse JSON data into a dictionary
//                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let data = jsonObject["data"] as? [String: Any]
//                   {
//
//
//                    print("No data received",data)
//
//                    // Extract car details
//
//
//                }
//            } catch {
//                print("Error parsing JSON: \(error.localizedDescription)")
//            }
//        }
//
//        // Start the data task
//        task.resume()
//    }
  func DoPayment(amount: Double, productDescription: String, tripId: Int) {
        // API endpoint URL
        let url = URL(string: Config.Backend + "payment/mmg/payment-link")!
        
        // Round the amount to the nearest whole number
        let roundedAmount = round(amount)
        
        // Create URLRequest with the URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Set method to POST
        
        // Add Bearer token to the request header
        let token = UserDefaultsConfig.jwtToken
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Set content type to JSON
        
        // Create the body data with PaymentRequest parameters
        let paymentRequest = [
            "amount": roundedAmount,
            "productDescription": productDescription,
            "tripId": tripId
        ] as [String: Any]
        
        // Convert the dictionary to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: paymentRequest, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        
        // Create URLSession
        let session = URLSession.shared
        
        // Create data task to send the POST request
        let task = session.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // Check if there's a response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No HTTP response")
                return
            }
            
            // Check the status code
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP Error: \(httpResponse.statusCode)")
                return
            }
            
            // Check if data is received
            guard let data = data else {
                print("No data received")
                return
            }

            do {
                // Parse JSON data into a dictionary
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let responseData = jsonObject["data"] as? [String: Any] {
                    
                    print("Response Data:", responseData)
                    
                    // Extract URL from the response
                    if let paymentUrl = responseData["url"] as? String {
                        DispatchQueue.main.async {
                            // Handle UI updates on the main thread
                            let viewController = PaymentWebPageViewController()
                            viewController.url = paymentUrl
                            
                            // Extract token from the URL query parameters if needed
                            if let url = URL(string: paymentUrl),
                               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                               let queryItems = components.queryItems {
                                if let token = queryItems.first(where: { $0.name == "token" })?.value {
                                    print("Token: \(token)")
                                    // Use the token as needed
                                    // self.tokenPaypal = token
                                }
                            }
                            
                            // Set the delegate and present the PaymentWebPageViewController
                            viewController.delegate = self
                            self.present(viewController, animated: true, completion: nil)
                        }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Start the data task
        task.resume()
    }


    
    
    @IBAction func checkoutaction(_ sender: Any) {
        DoPayment(amount: amount ?? 0.0, productDescription: "Payment", tripId: Request.shared.id ?? 0)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension WalletNewViewController: WebPaymentResultDelegate {
    func paid(token:String , transactonID :String) {
//        _ = self.navigationController?.popViewController(animated: true)
//        SPAlert.present(title: NSLocalizedString("Payment Successful", comment: ""), preset: .done)
//
      //  self.doPayment(token: token, amount: amount! , transactionId: transactonID)

    }
    
    func canceled() {
        
    }
}
