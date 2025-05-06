//
//  PaymentmethodViewController.swift
//  rider
//
//  Created by Apple on 26/11/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit

class PaymentmethodViewController: UIViewController {
    // Outlets for the buttons (connect these from the storyboard)
    @IBOutlet weak var onlineButton: UIButton!
    @IBOutlet weak var cashButton: UIButton!
    var rider: Rider!

    var selectedPaymentMethod: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onlineButton.setTitle("", for: .normal)
        cashButton.setTitle("", for: .normal)
        setupUI()
        
        if let userdata = UserDefaults.standard.dictionary(forKey: "Userdata") {
            let email = userdata["email"] as? String
            print("User Email: \(email ?? "No Email Found")")
        } else {
            print("No user data found in UserDefaults.")
        }

//        if let currentUser = UserManager.shared.currentUser?.email {
//              print("Current User: \(user)")
//          } else {
//              print("No user data available in UserManager.")
//          }
        
        
//           selectPaymentMethod(user)

        
    }
    
    // Setup initial UI
    func setupUI() {
      
        onlineButton.setImage(UIImage(named: "RadioOnB"), for: .normal)
        cashButton.setImage(UIImage(named: "RadioOffB"), for: .normal)
        
    }
    
    // Action when "Online" is tapped
    @IBAction func onlineButtonTapped(_ sender: UIButton) {
        selectPaymentMethod("Online")
    }
    
    // Action when "Cash" is tapped
    @IBAction func cashButtonTapped(_ sender: UIButton) {
        selectPaymentMethod("Cash")
    }
    
    // Logic to handle selection
    func selectPaymentMethod(_ method: String) {
        selectedPaymentMethod = method
        
        if method == "Online" {
            // Set online button as selected with blue circle
            onlineButton.setImage(UIImage(named: "RadioOnB"), for: .normal) // Default blue circle for selected
            cashButton.setImage(UIImage(named: "RadioOffB"), for: .normal)
        } else if method == "Cash" {
            onlineButton.setImage(UIImage(named: "RadioOffB"), for: .normal)
            cashButton.setImage(UIImage(named: "RadioOnB"), for: .normal)
        }
        
        print("Selected Payment Method: \(method)")
    }
    
    
    @IBAction func verifybutton(_ sender: UIButton) {
//        self.hideSideMenu()
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
                        self.navigationController!.pushViewController(vc, animated: true)
                }
        
    }
}
