//
//  OtpVerification.swift
//  rider
//
//  Created by Rohit wadhwa on 21/08/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit
import OTPFieldView
import FirebaseAuth
import FirebaseMessaging
import SPAlert
class OtpVerification: UIViewController , UITextFieldDelegate{
   
    @IBOutlet var otpTextFieldView: OTPFieldView!
    var PhoneNumber : String = ""
    var verificationID: String?
    var verificationCode : String = ""
    var From : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)

        self.title = "Otp verification".uppercased()
        setupOtpView()  // Make sure this line is present
        setupGestureRecognizer() // To dismiss keyboard when tapping outside
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    deinit {
           NotificationCenter.default.removeObserver(self)
       }

       func setupGestureRecognizer() {
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
       }

       @objc func dismissKeyboard() {
           view.endEditing(true) // Dismiss the keyboard
       }
    
    @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardHeight = keyboardFrame.cgRectValue.height
                self.view.frame.origin.y = -keyboardHeight // Adjust the view upwards
            }
        }

        // Reset view when keyboard disappears
        @objc func keyboardWillHide(notification: NSNotification) {
            self.view.frame.origin.y = 0 // Reset the view position
        }
        
    func verify(){
        
                guard let verificationID = verificationID else { return }
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    
                    authResult?.user.getIDToken(completion: { token, error in
                          if let error = error {
                              print("Error getting ID token: \(error.localizedDescription)")
                              return
                          }
                          
                          if let token = token {
                              print("Auth token: \(token)")
                              // Use the token as needed
                              print("User signed in successfully",authResult ?? "")
                              // Handle successful sign-in, navigate to the next screen
                              
                              
                              self.makePostRequestforverify(token: token)
                          }
                      })
                   
                }
            }
    
    func connectSocket(token:String) {
        Messaging.messaging().token() { (fcmToken, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
                if let token = UserDefaultsConfig.jwtToken {
                    self.connectSocket(token: token)
                }
            }
            SocketNetworkDispatcher.instance.connect(namespace: .Rider, token: token, notificationId: fcmToken ?? "") { result in
                switch result {
                case .success(_):
                    UserDefaults.standard.set("yes", forKey: "Firsttyme")

                    
//                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
//
//                        self.navigationController!.pushViewController(vc, animated: true)
//                    }
                
                    self.performSegue(withIdentifier: "segueHost", sender: nil)
                    
                case .failure(let error):
                    switch error {
                    case .NotFound:
                        let title = NSLocalizedString("Message", comment: "Message Default Title")
                        let dialog = UIAlertController(title: title, message: "User Info not found. Do you want to register again?", preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "Register", style: .default) { action in
//                            self.onLoginClicked(self.buttonLogin)
                        })
                        dialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(dialog, animated: true, completion: nil)
                        
                    default:
                        SPAlert.present(title: "Error", message: error.rawValue, preset: .error)
//                        self.indicatorLoading.isHidden = true
//                        self.textLoading.isHidden = true
//                        self.buttonLogin.isHidden = false
                    }
                }
            }
        }
    }
    
    @IBAction func VerifyOtp(_ sender: Any) {

        verify()
    }
    
    func makePostRequestforverify(token: String) {
        let url = URL(string: Config.Backend + "rider/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let phoneNumber = PhoneNumber.replacingOccurrences(of: "+", with: "")
        
        let parameters: [String: Any] = [
            "mobileNumber": phoneNumber,
            "firebaseToken": token
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
                    
                    
                    if (jsonResponse.data?.user?.status == "pending approval" ){
                        if let token = jsonResponse.token {
                            print("Token received: \(token)")
                            // You can save the token if needed
                           // UserDefaultsConfig.jwtToken = token
//                            UserDefaults.standard.set("yes", forKey: "Firsttyme")
//                           // self.connectSocket(token:token)
                            UserDefaultsConfig.jwtTokenNew = token

                            if let user = jsonResponse.data?.user {
                                UserManager.shared.currentUser = user
                                print("User details saved in UserManagerrrr.")
                              
                                UserDefaultsConfig.user = try jsonResponse.data?.user.asDictionary()
                            }
                            self.GotoProfile(token : token)
                        }
                      
                    }else{
                        
                        
                        if let user = jsonResponse.data?.user {
                            UserManager.shared.currentUser = user
                            print("User details saved in UserManagersss.")
                          
                            UserDefaultsConfig.user = try jsonResponse.data?.user.asDictionary()
                        }
                        // Handle the token if needed
                        if let token = jsonResponse.token {
                            print("Token received: \(token)")
                            // You can save the token if needed
                            UserDefaultsConfig.jwtToken = token
                            UserDefaultsConfig.jwtTokenNew = token

                            UserDefaults.standard.set("yes", forKey: "Firsttyme")
                            self.connectSocket(token:token)
                        }
                        
                        
                       // self.connectSocket(token:token)
                    }
                }
            } catch let jsonError {
                print("JSON error: \(jsonError.localizedDescription)")
            }
        }.resume()
    }
    func GotoProfile(token : String){
        DispatchQueue.main.async {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Profileedit") as? Profileedit {
                vc.phoneNumb = self.PhoneNumber
                vc.userToken = token
                self.navigationController!.pushViewController(vc, animated: true)
            }
            
        }
    }
    func setupOtpView(){
            self.otpTextFieldView.fieldsCount = 6
            self.otpTextFieldView.fieldBorderWidth = 2
            self.otpTextFieldView.defaultBorderColor = UIColor.black
            self.otpTextFieldView.filledBorderColor = UIColor.black
            self.otpTextFieldView.cursorColor = UIColor.red
            self.otpTextFieldView.displayType = .underlinedBottom
            self.otpTextFieldView.fieldSize = 40
            self.otpTextFieldView.separatorSpace = 8
            self.otpTextFieldView.shouldAllowIntermediateEditing = false
            self.otpTextFieldView.delegate = self
        
            self.otpTextFieldView.initializeUI()
        }
    
}
enum DisplayType: Int {
    case circular
    case roundedCorner
    case square
    case diamond
    case underlinedBottom
}
extension OtpVerification: OTPFieldViewDelegate {
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
        
    }
    
    func enteredOTP(otp otpString: String) {
        print("OTPString: \(otpString)")
        verificationCode = otpString
    }
}
class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    var currentUser: UserResponse?
}
