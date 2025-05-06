

import Foundation
import UIKit
import MaterialComponents
import FirebaseAuth
import ProgressHUD

class Enterphonenumber: UIViewController {
    var EulaTextStr = String()
    var mobileTextStr = String()
  
    @IBOutlet weak var VerifySource: ColoredButton!
    @IBOutlet weak var whatsappButton: UIButton!
    @IBOutlet weak var smsButton: UIButton!
    private var selectedOption: String?
    
    @IBAction func verifyAction(_ sender: Any) {
        if   selectedOption == "SMS"{
            makePostRequestforverify()
        }
        
        else if   selectedOption == "WhatsApp"{
            makePostRequestforverify()
        }
       
    }
    
    var verificationID: String?
    @IBAction func buttonTapped(_ sender: UIButton) {
        // Update selection based on which button is tapped
        updateSelection(selectedButton: sender)
    }
    
    func sentOTP() {
        ProgressHUD.animate("Loading")
        let phoneNumber = mobileTextStr
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            guard let self = self else {
                return
            }
            
            ProgressHUD.dismiss()
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                print("Error details: \(error)")
                return
            }
              
            guard let verificationID = verificationID else {
                print("Verification ID is nil.")
                return
            }
            
            self.verificationID = verificationID
            print("Verification code sent to \(phoneNumber)")
            
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OtpVerification") as? OtpVerification  {
                vc.verificationID = verificationID
                vc.PhoneNumber = phoneNumber
                vc.From = "Registration"
                self.navigationController?.pushViewController(vc, animated: true)
            
            }
        }
    }

    
    

//    func sentOTP(){
//        ProgressHUD.animate("Loading")
//        let phoneNumber = mobileTextStr
//        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                ProgressHUD.dismiss()
//                return
//            }
//            self.verificationID = verificationID
//            print("Verification code sent to \(phoneNumber)")
//            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OtpVerification") as? OtpVerification {
//                vc.verificationID =  self.verificationID ?? ""
//                vc.PhoneNumber = phoneNumber
//                vc.From = "Registration"
//                self.navigationController!.pushViewController(vc, animated: true)
//                ProgressHUD.dismiss()
//
//            }
//            
//        }
//    }

   
    
    
    func makePostRequestforverify() {
           let url = URL(string: Config.Backend + "rider")!
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           let phoneNumber = mobileTextStr.replacingOccurrences(of: "+", with: "")
//        let token = UserDefaultsConfig.jwtToken ?? ""

           let parameters: [String: Any] = [
               "mobileNumber": phoneNumber,
               "eula": EulaTextStr,
               "communication_preference" : "sms"
           ]
           print(parameters)
           guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
           request.httpBody = httpBody

           let session = URLSession.shared
           session.dataTask(with: request) { data, response, error in
               if let error = error {
                   print("Error: \(error.localizedDescription)")
                   return
               }
               
               if let httpResponse = response as? HTTPURLResponse {
                   print("HTTP Response Code: \(httpResponse.statusCode)")
               }

               guard let data = data else {
                   print("No data received")
                   return
               }

               if let responseString = String(data: data, encoding: .utf8) {
                   print("Raw Response: \(responseString)")
               }

               do {
                   let jsonResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                   print("Parsed Response: \(jsonResponse)")

                   if let success = jsonResponse.success, success {
                       DispatchQueue.main.async {
                           
                           self.sentOTP()
                         
                           print("succestt")
                           
                           
                       }
                   } else {
                       print("Login failed: Success was nil or false")
                   }
               } catch let jsonError {
                   print("JSON Parsing Error: \(jsonError.localizedDescription)")
               }
           }.resume()
       }

    
    override func viewDidLoad() {
        whatsappButton.setTitle("", for: .normal)
        smsButton.setTitle("", for: .normal)

        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        updateSelection(selectedButton: smsButton)

        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationItem.backButtonTitle = ""
        

        
    }
    private func updateSelection(selectedButton: UIButton) {
        // Reset all buttons
        resetButtonState()

        // Update UI for the selected button
        selectedButton.setImage(UIImage(named: "radioon"), for: .normal)
        
        // Update the selected option
        if selectedButton == smsButton {
            selectedOption = "SMS"
            
            
        }
        
        print("Selected option: \(selectedOption ?? "")")
    }
    
    private func resetButtonState() {
        // Reset both buttons to unselected state
        smsButton.setImage(UIImage(named: "radiooff"), for: .normal)
        whatsappButton.setImage(UIImage(named: "radiooff"), for: .normal)
    }
}


import UIKit

extension UIView {
    func showToast(message: String, duration: Double = 2.0) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true

        // Calculate size and position
        let textSize = toastLabel.sizeThatFits(CGSize(width: self.frame.size.width - 40, height: CGFloat.greatestFiniteMagnitude))
        let labelWidth = min(textSize.width + 20, self.frame.size.width - 40)
        let labelHeight = textSize.height + 10

        toastLabel.frame = CGRect(x: (self.frame.size.width - labelWidth) / 2,
                                  y: self.frame.size.height - 100,
                                  width: labelWidth,
                                  height: labelHeight)

        self.addSubview(toastLabel)

        // Animation for fade-out and removal
        UIView.animate(withDuration: 1.0, delay: duration, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
}
