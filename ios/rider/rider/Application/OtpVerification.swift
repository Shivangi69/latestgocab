//
//  OtpVerification.swift
//  rider
//
//  Created by Rohit wadhwa on 21/08/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit
import OTPFieldView
class OtpVerification: UIViewController , UITextFieldDelegate{
   
    @IBOutlet var otpTextFieldView: OTPFieldView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOtpView()  // Make sure this line is present

    }
    
    func setupOtpView(){
            self.otpTextFieldView.fieldsCount = 5
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
    }
}
