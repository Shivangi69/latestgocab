//
//  Profileedit.swift
//  rider
//
//  Created by Rohit wadhwa on 20/08/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import Foundation
import MaterialComponents
import OTPFieldView
import Photos
import Kingfisher

class Profileedit: UIViewController,UITextFieldDelegate {

  
    @IBOutlet weak var verifyButtonICON: UIImageView!
    @IBOutlet weak var Name: MDCOutlinedTextField!
    var msgbox = DevPopUp()
var varifiedEmail = String()
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var Email: MDCOutlinedTextField!
    @IBOutlet weak var verifyButttton: UIButton!
    @IBOutlet weak var phoneNumbLble: UILabel!
    var phoneNumb = String()
    var DOCORPROFILE = String()
    var DocNAme = String()
    var IDIMAGE = UIImage()

    var userToken = String()// Replace with the user's actual token
    var verificationCode = String()
    let user = try! Rider(from: UserDefaultsConfig.user!)

    @IBOutlet weak var otpTextview: OTPFieldView!
    @IBOutlet var OTPPopup: UIView!
    @IBOutlet weak var EmailLabel: UILabel!
    @IBAction func editProfile(_ sender: Any) {
    }
    @IBAction func EditImageation(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "Choose an option", preferredStyle: .actionSheet)
        
        // Camera option
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.DOCORPROFILE = "PROFILE"

            self.openCamera()
        }))
        
        // Gallery option
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.DOCORPROFILE = "PROFILE"

            self.openGallery()
        }))
        
        // Cancel option
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the action sheet
        self.present(actionSheet, animated: true, completion: nil)
    }
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true // Allow user to edit the image (optional)
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Camera not available", message: "Your device doesn't support the camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // Function to open the gallery
    func openGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true // Allow user to edit the image (optional)
        self.present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func UploadID(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Upload Document or Image", message: "Choose an option", preferredStyle: .actionSheet)
        
        // File option (e.g. .doc, .pdf)
        actionSheet.addAction(UIAlertAction(title: "Upload Document", style: .default, handler: { _ in
            self.DOCORPROFILE = "PDF"
            if #available(iOS 14.0, *) {
                self.openDocumentPicker()
            } else {
                // Fallback on earlier versions
            }
        }))
        
        // Camera option
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.DOCORPROFILE = "DOC"
            self.openCamera()
        }))
        
        // Gallery option
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.DOCORPROFILE = "DOC"

            self.openGallery()
        }))
        
        // Cancel option
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the action sheet
        self.present(actionSheet, animated: true, completion: nil)
    }
    @available(iOS 14.0, *)
    func openDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .jpeg, .png,.text], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false // Set to true if you want to allow multiple file selection
        self.present(documentPicker, animated: true, completion: nil)
    }
    @IBAction func GoANdVErify(_ sender: Any) {
        verifyEmailOTP(email: Email.text ?? "", otp: verificationCode)
    }
    @IBAction func GoNEedAssitance(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AssistanceViewController") as? AssistanceViewController {
           
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    @IBAction func RequestActivationGO(_ sender: Any) {
        uploadProfileData()
    }
    @IBAction func cancelButton(_ sender: Any) {
    }
    @IBAction func verifyButton(_ sender: Any) {
        
        guard let email = Email.text, !email.isEmpty else {
                   // Show alert if email is empty
                   return
               }
               sendEmailVerification(email: email)
    }
    
    

    func uploadProfileData() {
        guard let profileImage = profileImage.image else { return }
        
        // Convert the profile image to Data
        let profileImageData = profileImage.jpegData(compressionQuality: 0.8)
        
        // Prepare the request URL
        guard let url = URL(string: Config.Backend + "rider") else { return }
        
        // Create the request and set headers
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        let boundary = UUID().uuidString
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Prepare multipart form data
        var body = Data()
        
        // Add profile image to the body
        if self.DOCORPROFILE == "PROFILE", let imageData = profileImageData {
            body.append(convertFileData(fieldName: "profile", fileName: "profile.jpg", mimeType: "image/jpeg", fileData: imageData, using: boundary))
        }
        
        // Add document (if applicable) to the body
        if self.DOCORPROFILE == "PDF" {
            if let docURL = URL(string: self.DocNAme) { // Assuming self.DocNAme is the file path
                do {
                    let fileData = try Data(contentsOf: docURL)
                    let fileExtension = docURL.pathExtension.lowercased()
                    let mimeType = fileExtension == "pdf" ? "application/pdf" : "application/msword"
                    body.append(convertFileData(fieldName: "id", fileName: "document.\(fileExtension)", mimeType: mimeType, fileData: fileData, using: boundary))
                } catch {
                    print("Error reading file: \(error.localizedDescription)")
                }
            }
        }
        
        // Add other fields (firstName, email)
        let firstNameData = self.Name.text ?? ""
        body.append(convertFormField(named: "firstName", value: firstNameData, using: boundary))
        
        
        let lastName = "wadhwa" 
        body.append(convertFormField(named: "lastName", value: firstNameData, using: boundary))
       
        let emailData = self.Email.text ?? ""
        body.append(convertFormField(named: "email", value: emailData, using: boundary))
        
        // Close the body with the boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Set the body of the request
        request.httpBody = body
        
        // Start the request using URLSession
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading: \(error)")
                return
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
        }
        
        task.resume()
    }

    // Helper function to convert form fields to Data
    func convertFormField(named name: String, value: String, using boundary: String) -> Data {
        var fieldData = "--\(boundary)\r\n".data(using: .utf8)!
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        fieldData.append("\(value)\r\n".data(using: .utf8)!)
        return fieldData
    }

    // Helper function to convert file data to Data for multipart/form-data
    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        var fileDataSection = Data()
        
        fileDataSection.append("--\(boundary)\r\n".data(using: .utf8)!)
        fileDataSection.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        fileDataSection.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        fileDataSection.append(fileData)
        fileDataSection.append("\r\n".data(using: .utf8)!)
        
        return fileDataSection
    }

    
    
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    func setupOtpView(){
          
        self.otpTextview.fieldsCount = 6
            self.otpTextview.fieldBorderWidth = 2
            self.otpTextview.defaultBorderColor = UIColor.black
            self.otpTextview.filledBorderColor = UIColor.black
            self.otpTextview.cursorColor = UIColor.red
            self.otpTextview.displayType = .underlinedBottom
            self.otpTextview.fieldSize = 40
            self.otpTextview.separatorSpace = 8
            self.otpTextview.shouldAllowIntermediateEditing = false
            self.otpTextview.delegate = self
        
            self.otpTextview.initializeUI()
        }
    @IBOutlet weak var Uploadid: MDCOutlinedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)

        self.title = "Edit profile".uppercased()
        
        Name.label.text = "Name*"
        Name.placeholder = "Name"
        Name.sizeToFit()
        uploadButton.setTitle("", for: .normal)
        Email.label.text = "Email*"
        Email.placeholder = "Email"
        Email.sizeToFit()
        setupOtpView()
        Uploadid.label.text = "Upload ID*"
        Uploadid.placeholder = "Upload ID"
        Uploadid.sizeToFit()
        phoneNumbLble.text = phoneNumb
        Email.addTarget(self, action: #selector(emailTextChanged(_:)), for: .editingChanged)
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.layer.masksToBounds = true
        Name.delegate = self
        Email.delegate = self
        Uploadid.delegate = self
        Name.text = (user.firstName ?? "") + " " + (user.lastName ?? "")
        Email.text = (user.email ?? "")
//        Uploadid.text = user.id
        
        if let riderImage = user.media?.address {
            let processor = DownsamplingImageProcessor(size: profileImage.intrinsicContentSize) |> RoundCornerImageProcessor(cornerRadius: profileImage.intrinsicContentSize.width / 2)
            let url = URL(string: Config.Backend + riderImage.replacingOccurrences(of: " ", with: "%20"))
            profileImage.kf.setImage(with: url, placeholder: UIImage(named: "Nobody"), options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage
            ], completionHandler: { result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            })
        }
        
        
    }
    @objc func emailTextChanged(_ textField: UITextField) {
        
        if varifiedEmail == textField.text  &&  textField.text != "" {
            isEmailVerified = true
            verifyButttton.isHidden = true
            verifyButtonICON.isHidden = false
        }else{
            isEmailVerified = false

            verifyButttton.isHidden = false
            verifyButtonICON.isHidden = true
        }
       
    }
    
    func sendEmailVerification(email: String) {
            
            // Call the emailVerify API
        let url = URL(string: Config.Backend + "rider/send/otp/email")!

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(userToken )", forHTTPHeaderField: "Authorization")
        
        let parameters: [String: Any] = [
            "email": email
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody

        
        
//            do {
//                let jsonData = try JSONEncoder().encode(emailVerifyRequest)
//                request.httpBody = jsonData
//            } catch {
//                print("Error encoding JSON: \(error)")
//                return
//            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do
//                {
//                    let jsonResponse = try JSONDecoder().decode(RiderSignupResponse.self, from: data)
//                    if jsonResponse.success {
//                        // Show OTP popup
//                        self.showOTPPopup(email: email)
//                    }
//                }
                {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Response JSON: \(jsonResponse)")
                        self.showOTPPopup(email: email)
                    }
                }
                catch let error {
                    print("JSON Parsing error: \(error.localizedDescription)")
                }
            }.resume()
        }
    func showOTPPopup(email: String) {
        DispatchQueue.main.async {
            self.view.endEditing(true)

            //            let alert = UIAlertController(title: "Enter the 6-digit code we sent to", message: email, preferredStyle: .alert)
            //
            //            // Adding 6 TextFields for each digit of the OTP
            //            for _ in 0..<6 {
            //                alert.addTextField { textField in
            //                    textField.keyboardType = .numberPad
            //                    textField.textAlignment = .center
            //                    textField.placeholder = "-"
            //                }
            //            }
            //
            //            // Customizing the buttons
            //            let verifyAction = UIAlertAction(title: "VERIFY", style: .default) { [weak alert] _ in
            //                // Gather the OTP from all the fields
            //                var otp = ""
            //                if let textFields = alert?.textFields {
            //                    for textField in textFields {
            //                        if let digit = textField.text, !digit.isEmpty {
            //                            otp += digit
            //                        }
            //                    }
            //                }
            //                print("Entered OTP: \(otp)")
            //                // Call your API to verify OTP here
            //            }
            //            let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
            //
            //            // Customizing buttons with your desired styles
            //            verifyAction.setValue(UIColor.yellow, forKey: "titleTextColor")
            //            cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
            //
            //            // Adding actions to the alert
            //            alert.addAction(verifyAction)
            //            alert.addAction(cancelAction)
            //
            //            // Presenting the custom alert
            //            self.present(alert, animated: true, completion: nil)
            //
            //        }
            self.msgbox =  self.msgbox.popUpWithView(_view: self.OTPPopup, onController: self)
            self.EmailLabel.text = self.Email.text
            self.msgbox.show()
            
        }
        }
    var isEmailVerified = false
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // This will dismiss the keyboard
            return true
        }
        func verifyEmailOTP(email: String, otp: String) {
            let emailOTPVerifyRequest = EmailOTPVerifyRequest(email: email, enteredOtp: otp)
            let url = URL(string: Config.Backend + "rider/verify/email")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(userToken )", forHTTPHeaderField: "Authorization")

            do {
                let jsonData = try JSONEncoder().encode(emailOTPVerifyRequest)
                request.httpBody = jsonData
            } catch {
                print("Error encoding JSON: \(error)")
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
//                    let jsonResponse = try JSONDecoder().decode(RiderSignupResponse.self, from: data)
//                    if jsonResponse.success {
//                        DispatchQueue.main.async {
//                            // Email verified, show verified icon
//                            self.verifyButtonICON.isHidden = false
//                            self.verifyButttton.isHidden = true
//                        }
//                    }
//
                    
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        print("Response JSON: \(jsonResponse)")
//                        self.showOTPPopup(email: email)
                        if let success = jsonResponse["success"] as? Int, success == 1 {
                            // Call your function here
                            DispatchQueue.main.async {
                                // Email verified, show verified icon
                                self.verifyButtonICON.isHidden = false
                                self.verifyButttton.isHidden = true
                                self.isEmailVerified = true
                                self.msgbox.dismiss(value: true)
                                self.varifiedEmail = email
                            }
                        }else{
                         
                           
                        }
                    }
                }
                catch let error {
                    print("JSON Parsing error: \(error.localizedDescription)")
                }
            }.resume()
        }
   
}

struct EmailVerifyRequest: Codable {
    let email: String
}

struct EmailOTPVerifyRequest: Codable {
    let email: String
    let enteredOtp: String
}

struct RiderSignupResponse: Codable {
    let success: Bool
}
extension Profileedit: OTPFieldViewDelegate {
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
extension Profileedit: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if DOCORPROFILE == "PROFILE"{
            if let editedImage = info[.editedImage] as? UIImage {
                profileImage.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                profileImage.image = originalImage
            }
            
        }
        else{
            if let editedImage = info[.editedImage] as? UIImage {
                IDIMAGE = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                IDIMAGE = originalImage
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
extension Profileedit: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        
        // Do something with the selected file (e.g., upload it to your server)
        print("Selected file: \(selectedFileURL.lastPathComponent)")
        
        // Handle document selection (e.g., upload or save the document)
        // You can also check the file extension here and process accordingly.
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled")
    }
}
