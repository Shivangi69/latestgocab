//
//  OtpVerification.swift
//  rider
//
//  Created by Rohit wadhwa on 21/08/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import OTPFieldView
import FirebaseAuth
import FirebaseMessaging
import SPAlert
import ProgressHUD

class OtpVerification: UIViewController , UITextFieldDelegate{
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var resendButton: UIButton!
    @IBOutlet var uistack: UIStackView!

    let countrycodevc =  CountryCodeVC()
    var timer: Timer?
       var totalTime = 119 // 1:59 in seconds
       
    @IBOutlet var label: UILabel!
    @IBOutlet var hidelabel: UILabel!

    @IBOutlet var otpTextFieldView: OTPFieldView!
    var PhoneNumber : String = ""
    var verificationID: String?
    var verificationCode : String = ""
    var From : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        // Retrieve the saved phone number from UserDefaults
        if let savedPhoneNumber = UserDefaults.standard.string(forKey: "phoneNumber") {
            self.label.text = savedPhoneNumber
        }
        
        self.title = "Otp verification".uppercased()
        setupOtpView()  // Make sure this line is present
        setupGestureRecognizer() // To dismiss keyboard when tapping outside
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setupResendCode()
        startTimer()
    }
    
    deinit {
           NotificationCenter.default.removeObserver(self)
       }
    
    func showAlertMessage(_ message : String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    func sentOTP() {
        let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber")
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber ?? "nil", uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                ProgressHUD.dismiss()
                self.showAlertMessage("Failure: \(error.localizedDescription)")
                print("Error: \(error.localizedDescription)")
                return
            }
            
            self.verificationID = verificationID
            print("Verification code sent to \(phoneNumber)")
            ProgressHUD.dismiss()
            
            // Show success message
            self.showAlertMessage("OTP sent successfully to \(phoneNumber)")
        }
    }

    func setupResendCode() {
        resendButton.isEnabled = false
        resendButton.alpha = 1.0
        
      }
      
      func startTimer() {
          timerLabel.text =  timeFormatted(totalTime)
          timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
          resendButton.isHidden = true

          
      }
      
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        
    }

    @objc func updateTimer() {
        if totalTime > 0 {
            totalTime -= 1
            timerLabel.text = timeFormatted(totalTime)
            print("Timer updated: \(timerLabel.text ?? "")") // Debug print
        } else {
            stopTimer() // Stop the timer when it's finished
            enableResendCode() // Enable the resend code button
        }
    }

    
    func enableResendCode() {
        resendButton.isEnabled = true
//        resendButton.alpha = 1.0 // Reset button appearance
        timerLabel.textAlignment = .center

        hidelabel.isHidden = true
        resendButton.isHidden = false
        
    }
      
      func timeFormatted(_ totalSeconds: Int) -> String {
          let minutes = totalSeconds / 60
          let seconds = totalSeconds % 60
          return String(format: "%d:%02d", minutes, seconds)
      }
      
    
    @IBAction func resendCodePressed(_ sender: Any) {
        print("Resend code tapped")
        // Reset timer to 1:59
        totalTime = 119
        setupResendCode()
        startTimer()
        let token = UserDefaults.standard.string(forKey: "authToken") ?? "defaultToken"
        makePostRequestforverify(token: token) // Make post request to verify the token
        sentOTP()
        timerLabel.textAlignment = .center
        hidelabel.isHidden = false
        timerLabel.isHidden = false
        resendButton.isHidden = true

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
                    UserDefaults.standard.set(token, forKey: "authToken")
                    
                    print("User signed in successfully",authResult ?? "")
                    
                    self.view.showToast(message: "Welcome to Gocab!")
                    
                    self.makePostRequestforverify(token: token)
                    self.stopTimer()
                    // Temporarily hide the navigation bar when pushing MainViewController
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

                    DispatchQueue.main.async {
                                      self.navigationController?.setNavigationBarHidden(true, animated: false)
                                      self.performSegue(withIdentifier: "segueHost", sender: nil)
                                  }
                    
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
                      
                    }
                    else {
                        
                        
                        if let user = jsonResponse.data?.user {
                            UserManager.shared.currentUser = user
                            print("User details saved in UserManagersss.")
                          
                            UserDefaultsConfig.user = try jsonResponse.data?.user?.asDictionary()
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
