

import Foundation
import UIKit
import MaterialComponents
import FirebaseAuth
import ProgressHUD

class Enterphonenumber: UIViewController {
    var EulaTextStr = String()
    var mobileTextStr = String()
//    @IBOutlet weak var Country: MDCOutlinedTextField!
//    
//    @IBOutlet weak var phonenumber: MDCOutlinedTextField!
//    
//    @IBOutlet weak var lblFlag: UITextField!
//    @IBOutlet weak var lblCountryCode: UILabel!
//    var countriesViewController = CountriesViewController()
//    
    @IBOutlet weak var VerifySource: ColoredButton!
    @IBOutlet weak var whatsaooButton: UIButton!
    @IBOutlet weak var SMSbutton: UIButton!
    //    var countryCode: String?
    @IBAction func verifyAction(_ sender: Any) {
        
        makePostRequestforverify()
    }
    
    var verificationID: String?

    
    
    func sentOTP(){
        ProgressHUD.animate("Loading")
        let phoneNumber = mobileTextStr
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                ProgressHUD.dismiss()
                return
            }
            self.verificationID = verificationID
            print("Verification code sent to \(phoneNumber)")
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OtpVerification") as? OtpVerification {
                vc.verificationID =  self.verificationID ?? ""
                vc.PhoneNumber = phoneNumber
                vc.From = "Registration"
                self.navigationController!.pushViewController(vc, animated: true)
                ProgressHUD.dismiss()

            }
            
        }
    }
    func makePostRequestforverify() {
        let url = URL(string: Config.Backend + "rider")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let phoneNumber = mobileTextStr.replacingOccurrences(of: "+", with: "")
        
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

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let jsonResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                print("Response JSON: \(jsonResponse)")

                if let success = jsonResponse.success, success {
                    // Store the user data in the UserManager
                    self.sentOTP()
                    // Handle the token if needed
                   
                }
            } catch let jsonError {
                print("JSON error: \(jsonError.localizedDescription)")
            }
        }.resume()
    }
    
    override func viewDidLoad() {
//        whatsaooButton.setTitle("", for: .normal)
//        SMSbutton.setTitle("", for: .normal)

        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)

        self.title = "Verify Phone".uppercased()
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationItem.backButtonTitle = ""
        
        //        initalSetup()
        
//        Country.label.text = "Country"
//        Country.placeholder = "+91"
//        Country.sizeToFit()
//        
//        
//        phonenumber.label.text = "Phone number"
//        phonenumber.textColor = .yellow
//        
//        phonenumber.placeholder = "Phone number"
//        phonenumber.sizeToFit()
//        
        
    }
}
