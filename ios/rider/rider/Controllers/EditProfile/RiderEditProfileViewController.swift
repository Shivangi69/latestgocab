////
////  EditProfileViewController.swift
////  Rider
////
////  Copyright © 2018 minimalistic apps. All rights reserved.
////
//import UIKit
import Eureka
import SPAlert
import ImageRow
import Kingfisher

//class RiderEditProfileViewController: FormViewController {
//    var downloading = false
//    var rider: Rider!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        rider = try! Rider(from: UserDefaultsConfig.user!)
//        form +++ Section(NSLocalizedString("Images", comment: "Profile's image section header"))
//            <<< ImageRow() {
//                $0.tag = "profile_row"
//                $0.title = NSLocalizedString("Profile Image", comment: "Profile's image field title")
//                $0.allowEditor = true
//                $0.useEditedImage = true
//                if let address = rider.media?.address {
//                    let url = URL(string: Config.Backend + address.replacingOccurrences(of: " ", with: "%20"))
//                    ImageDownloader.default.downloadImage(with: url!, completionHandler: { result in
//                        switch result {
//                        case .success(let value):
//                            self.downloading = true
//                            (self.form.rowBy(tag: "profile_row")! as! ImageRow).value = value.image
//                            (self.form.rowBy(tag: "profile_row")! as! ImageRow).reload()
//                            self.downloading = false
//                        case .failure(let error):
//                            print(error)
//                        }
//                    })
//                }
//                $0.sourceTypes = .PhotoLibrary
//                $0.clearAction = .no
//                }.onChange {
//                    if(!self.downloading) {
//                        let data = $0.value?.jpegData(compressionQuality: 0.7)
//                        $0.title = NSLocalizedString("Uploading, Please wait...", comment: "Uploading image state")
//                        $0.disabled = true
//                        $0.reload()
//                        UpdateProfileImage(data: data!).execute() { result in
//                            self.form.rowBy(tag: "profile_row")!.title = NSLocalizedString("Profile Image", comment: "Profile's image field title")
//                            self.form.rowBy(tag: "profile_row")!.disabled = false
//                            self.form.rowBy(tag: "profile_row")!.reload()
//                            switch result {
//                            case .success(let response):
//                                SPAlert.present(title: NSLocalizedString("Profile image updated", comment: ""), preset: .done)
//                                self.rider.media = response
//                                UserDefaultsConfig.user = try! self.rider.asDictionary()
//
//                            case .failure(let error):
//                                error.showAlert()
//                            }
//                        }
//                    }
//                }
//                .cellUpdate { cell, row in
//                    cell.accessoryView?.layer.cornerRadius = 17
//                    cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
//            }
//            +++ Section(NSLocalizedString("Basic Info", comment: "Profile Basic Info section header"))
//            <<< PhoneRow(){
//                $0.title = NSLocalizedString("Mobile Number", comment: "Profile Mobile Number field title")
//                $0.disabled = true
//                $0.value = String(rider.mobileNumber!)
//            }
//            <<< EmailRow(){
//                $0.title = NSLocalizedString("E-Mail", comment: "Profile Email field title")
//                $0.value = rider.email
//            }.onChange { self.rider.email = $0.value }
//            <<< TextRow(){
//                $0.title = NSLocalizedString("Name", comment: "Profile Name field")
//                $0.value = rider.firstName
//                $0.placeholder = NSLocalizedString("First Name", comment: "Profile First Name Field")
//                }.onChange { self.rider.firstName = $0.value }
//            <<< TextRow(){
//                $0.title = " "
//                $0.placeholder = NSLocalizedString("Last Name", comment: "Profile Last Name field")
//                $0.value = rider.lastName
//                }.onChange { self.rider.lastName = $0.value }
//            +++ Section(NSLocalizedString("Additional Info", comment: "Profile's additional Info section"))
//            <<< PushRow<String>() {
//                $0.title = NSLocalizedString("Gender", comment: "Profile's gender field title")
//                $0.selectorTitle = NSLocalizedString("Select Your Gender", comment: "Profile's gender field selector title")
//                $0.options = ["Male","Female","Unspecified"]
//                $0.value = rider.gender?.capitalizingFirstLetter()
//            }.onChange { self.rider.gender = ($0.value! as String).lowercased() }
//            <<< TextRow(){
//                $0.title = NSLocalizedString("Address", comment: "Profile Address field title")
//                $0.value = rider.address
//                }.onChange { self.rider.address = $0.value }
//    }
//    @IBAction func onSaveProfileClicked(_ sender: Any) {
//        UpdateProfile(user: self.rider).execute() { result in
//            switch result {
//            case .success(_):
//                _ = self.navigationController?.popViewController(animated: true)
//                UserDefaultsConfig.user = try! self.rider.asDictionary()
//
//            case .failure(let error):
//                error.showAlert()
//            }
//        }
//    }
//}
import UIKit
import SPAlert
import Kingfisher

import MaterialComponents

class RiderEditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    var downloading = false
    var rider: Rider!

    let menuview = MenuViewController()
    // UI Elements
    let scrollView = UIScrollView()
    let contentView = UIView()
    let profileImageView = UIImageView()
    let emailTextField = MDCOutlinedTextField()

    let mobileNumberLabel = MDCOutlinedTextField()
    let firstNameTextField = MDCOutlinedTextField()
    let lastNameTextField = MDCOutlinedTextField()
    let genderNameTextField = MDCOutlinedTextField()

    let addressTextField = MDCOutlinedTextField()
    let saveButton = UIButton(type: .system)
    let logoutButton = UIButton(type: .system)
    let deleteAccountButton = UIButton(type: .system)

    let genderSegmentedControl = UISegmentedControl(items: ["Male", "Female", "Unspecified"])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rider = try! Rider(from: UserDefaultsConfig.user!)

        setupUI()
        layoutUI()
        populateData()
    }

    func setupUI() {
        view.backgroundColor = .white
        title = "Your Account"

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.masksToBounds = true
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectProfileImage)))
        contentView.addSubview(profileImageView)

        
        mobileNumberLabel.label.text = NSLocalizedString("Mobile Number", comment: "Profile Mobile Number field title")
        mobileNumberLabel.placeholder = "Enter your mobile number"
        mobileNumberLabel.leadingView = UIImageView(image: UIImage(systemName: "phone")?.withTintColor(.systemFill))
        mobileNumberLabel.tintColor = .gray // Ensure icon color is always gray

        mobileNumberLabel.leadingViewMode = .always
        mobileNumberLabel.setOutlineColor(.gray, for: .normal)
        mobileNumberLabel.setNormalLabelColor(.gray, for: .normal)
        mobileNumberLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(mobileNumberLabel)

        emailTextField.label.text = NSLocalizedString("E-Mail", comment: "Profile Email field title")
        emailTextField.placeholder = "Enter your email"
        emailTextField.leadingView = UIImageView(image: UIImage(systemName: "envelope"))
        emailTextField.leadingViewMode = .always
        emailTextField.sizeToFit()

        // Styling
        emailTextField.tintColor = .gray

        emailTextField.setOutlineColor(.gray, for: .normal)
        emailTextField.setNormalLabelColor(.gray, for: .normal)
        emailTextField.font = UIFont.systemFont(ofSize: 14)

        contentView.addSubview(emailTextField)

        // Configure First Name TextField
        firstNameTextField.label.text = NSLocalizedString("First Name", comment: "Profile First Name field")
        firstNameTextField.tintColor = .gray // Ensure icon color is always gray
        firstNameTextField.placeholder = "Enter your first name"
        firstNameTextField.leadingView = UIImageView(image: UIImage(systemName: "person"))
        firstNameTextField.leadingViewMode = .always
        firstNameTextField.setOutlineColor(.gray, for: .normal)
        firstNameTextField.setNormalLabelColor(.gray, for: .normal)
        firstNameTextField.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(firstNameTextField)

        // Configure Last Name TextField
        lastNameTextField.label.text = NSLocalizedString("Last Name", comment: "Profile Last Name field")
        lastNameTextField.placeholder = "Enter your last name"
        lastNameTextField.leadingView = UIImageView(image: UIImage(systemName: "person"))
        lastNameTextField.leadingViewMode = .always
        lastNameTextField.tintColor = .gray // Ensure icon color is always gray
        lastNameTextField.setNormalLabelColor(.gray, for: .normal)
        lastNameTextField.font = UIFont.systemFont(ofSize: 14)
        
        contentView.addSubview(lastNameTextField)

        addressTextField.label.text = NSLocalizedString("Address", comment: "Profile Address field")
        addressTextField.placeholder = "Enter your address"
        addressTextField.leadingView = UIImageView(image: UIImage(systemName: "house"))
        addressTextField.leadingViewMode = .always
        addressTextField.setOutlineColor(.gray, for: .normal)
        addressTextField.tintColor = .gray // Ensure icon color is always gray

        addressTextField.setNormalLabelColor(.gray, for: .normal)
        addressTextField.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(addressTextField)
        
        
        
//        // First Name TextField
//        firstNameTextField.placeholder = NSLocalizedString("First Name", comment: "Profile First Name Field")
//        firstNameTextField.borderStyle = .roundedRect
//        contentView.addSubview(firstNameTextField)

//        // Last Name TextField
//        lastNameTextField.placeholder = NSLocalizedString("Last Name", comment: "Profile Last Name field")
//        lastNameTextField.borderStyle = .roundedRect
//        contentView.addSubview(lastNameTextField)

        // Gender Segmented Control
//        genderSegmentedControl.selectedSegmentIndex = 0
//        contentView.addSubview(genderSegmentedControl)

        genderNameTextField.label.text = NSLocalizedString("Gender", comment: "Profile Gender field")
        genderNameTextField.tintColor = .gray // Ensure icon color is always gray
        genderNameTextField.placeholder = "Enter Gender"
        genderNameTextField.leadingView = UIImageView(image: UIImage(systemName: "female.circle"))
        genderNameTextField.leadingViewMode = .always
        genderNameTextField.setOutlineColor(.gray, for: .normal)
        genderNameTextField.setNormalLabelColor(.gray, for: .normal)
        genderNameTextField.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(genderNameTextField)
        logoutButton.setTitle(NSLocalizedString("Logout", comment: "Logout button title"), for: .normal)
        logoutButton.setTitleColor(.blue, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        logoutButton.addTarget(self, action: #selector(resetAppAndNavigateToSplash), for: .touchUpInside)


        deleteAccountButton.setTitle(NSLocalizedString("Delete My Account", comment: "Delete my account button title"), for: .normal)
        deleteAccountButton.setTitleColor(.red, for: .normal)
        deleteAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//    deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonTapped), for: .touchUpInside)

        // Adding the buttons to the content view
        contentView.addSubview(logoutButton)
        contentView.addSubview(deleteAccountButton)
//
//        saveButton.setTitle(NSLocalizedString("Save", comment: "Save button title"), for: .normal)
//        saveButton.addTarget(self, action: #selector(onSaveProfileClicked), for: .touchUpInside)
//        contentView.addSubview(saveButton)
    }
    @objc func resetAppAndNavigateToSplash() {
        print("Logout button tapped")
        
        // Clear user defaults
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
            UserDefaults.standard.synchronize()
        }

        // Hide the side menu (if applicable)
        menuview.menuContainerViewController?.hideSideMenu()

        // Get the active window
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        // Instantiate the splash view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let splashViewController = storyboard.instantiateViewController(withIdentifier: "SplashViewController")

        // Reset the root view controller
        let navigationController = UINavigationController(rootViewController: splashViewController)
        window.rootViewController = navigationController

        // Add a transition animation (optional)
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: nil) { _ in
            window.makeKeyAndVisible()
        }
    }


    func layoutUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
           contentView.translatesAutoresizingMaskIntoConstraints = false
           profileImageView.translatesAutoresizingMaskIntoConstraints = false
           mobileNumberLabel.translatesAutoresizingMaskIntoConstraints = false
           emailTextField.translatesAutoresizingMaskIntoConstraints = false
           firstNameTextField.translatesAutoresizingMaskIntoConstraints = false
           lastNameTextField.translatesAutoresizingMaskIntoConstraints = false
          genderNameTextField.translatesAutoresizingMaskIntoConstraints = false
           addressTextField.translatesAutoresizingMaskIntoConstraints = false
//           saveButton.translatesAutoresizingMaskIntoConstraints = false

        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false

        let nameStackView = UIStackView(arrangedSubviews: [firstNameTextField, lastNameTextField])
        
         nameStackView.axis = .horizontal
         nameStackView.spacing = 10
         nameStackView.distribution = .fillEqually
         nameStackView.translatesAutoresizingMaskIntoConstraints = false
         contentView.addSubview(nameStackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            
            
            mobileNumberLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            mobileNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mobileNumberLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            emailTextField.topAnchor.constraint(equalTo: mobileNumberLabel.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Horizontal Name StackView
            nameStackView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            nameStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

//            firstNameTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
//            firstNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            firstNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//
//            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 20),
//            lastNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            lastNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            genderNameTextField.topAnchor.constraint(equalTo: nameStackView.bottomAnchor, constant: 20),
            genderNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            genderNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addressTextField.topAnchor.constraint(equalTo: genderNameTextField.bottomAnchor, constant: 20),
            addressTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addressTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
          
            logoutButton.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: 20),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
       
               
            deleteAccountButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 15),
            deleteAccountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
         
               
            
//            saveButton.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: 20),
//            saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    func populateData() {
        
        if let address = rider.media?.address {
            let url = URL(string: Config.Backend + address.replacingOccurrences(of: " ", with: "%20"))
            profileImageView.kf.setImage(with: url)
            
        }
        
        if let mobileNumber = rider.mobileNumber {
            mobileNumberLabel.text = String(mobileNumber) // For standard UILabel or MDCOutlinedTextField
        }
        
        emailTextField.text = rider.email
        firstNameTextField.text = rider.firstName
        lastNameTextField.text = rider.lastName
        genderNameTextField.text = rider.gender

        if let gender = rider.gender?.capitalizingFirstLetter() {
            genderSegmentedControl.selectedSegmentIndex = ["Male", "Female", "Unspecified"].firstIndex(of: gender) ?? 0
        }
        addressTextField.text = rider.address
    }

    @objc func selectProfileImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @objc func onSaveProfileClicked() {
        rider.email = emailTextField.text
        rider.firstName = firstNameTextField.text
        rider.lastName = lastNameTextField.text
        rider.gender = ["male", "female", "unspecified"][genderSegmentedControl.selectedSegmentIndex]
        rider.address = addressTextField.text

        UpdateProfile(user: self.rider).execute() { result in
            switch result {
            case .success(_):
                _ = self.navigationController?.popViewController(animated: true)
                UserDefaultsConfig.user = try! self.rider.asDictionary()

            case .failure(let error):
                error.showAlert()
            }
        }
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            profileImageView.image = image
            let data = image.jpegData(compressionQuality: 0.7)

            UpdateProfileImage(data: data!).execute() { result in
                switch result {
                case .success(let response):
                    SPAlert.present(title: NSLocalizedString("Profile image updated", comment: ""), preset: .done)
                    self.rider.media = response
                    UserDefaultsConfig.user = try! self.rider.asDictionary()

                case .failure(let error):
                    error.showAlert()
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//import UIKit

//class RiderEditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    let scrollView = UIScrollView()
//    let contentView = UIView()
//
//    let profileImageView = UIImageView()
//    let uploadButton = UIButton()
//    let mobileNumberTextField = UITextField()
//    let emailTextField = UITextField()
//    let firstNameTextField = UITextField()
//    let lastNameTextField = UITextField()
//    let genderSegmentedControl = UISegmentedControl(items: ["Male", "Female", "Transgender"])
//    let addressTextField = UITextField()
//    let saveButton = UIBarButtonItem()
//    let logoutButton = UIButton()
//    let deleteAccountButton = UIButton()
//
//    var rider: Rider!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        rider = try! Rider(from: UserDefaultsConfig.user!)
//        setupUI()
//        populateData()
//    }
//
//    func setupUI() {
//        view.backgroundColor = .white
//        title = "Your Account"
//
//        saveButton.title = "SAVE"
//        saveButton.style = .done
//        saveButton.target = self
//        saveButton.action = #selector(onSaveProfileClicked)
//        navigationItem.rightBarButtonItem = saveButton
//
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
//        ])
//
//
//        profileImageView.translatesAutoresizingMaskIntoConstraints = false
//        profileImageView.layer.cornerRadius = 50
//        profileImageView.clipsToBounds = true
//        profileImageView.contentMode = .scaleAspectFill
//        contentView.addSubview(profileImageView)
//
//        NSLayoutConstraint.activate([
//            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            profileImageView.widthAnchor.constraint(equalToConstant: 100),
//            profileImageView.heightAnchor.constraint(equalToConstant: 100)
//        ])
//
//        uploadButton.translatesAutoresizingMaskIntoConstraints = false
//        uploadButton.setImage(UIImage(systemName: "icloud.and.arrow.up.fill"), for: .normal)
//        uploadButton.backgroundColor = UIColor(named: "ThemeYellow")
//        uploadButton.tintColor = .black
//        uploadButton.layer.cornerRadius = 20
//        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
//        contentView.addSubview(uploadButton)
//
//        NSLayoutConstraint.activate([
//            uploadButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
//            uploadButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
//            uploadButton.widthAnchor.constraint(equalToConstant: 40),
//            uploadButton.heightAnchor.constraint(equalToConstant: 40)
//        ])
//
//        setupTextField(mobileNumberTextField, placeholder: "Mobile Number", isEnabled: false)
//        mobileNumberTextField.text =  String(rider.mobileNumber!)
//
//        setupTextField(emailTextField, placeholder: "E-Mail")
//        emailTextField.text = rider.email
//
//        setupTextField(firstNameTextField, placeholder: "First Name")
//        firstNameTextField.text = rider.firstName
//
//        setupTextField(lastNameTextField, placeholder: "Last Name")
//        lastNameTextField.text = rider.lastName
//
//        genderSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(genderSegmentedControl)
//
//        genderSegmentedControl.selectedSegmentIndex = rider.gender == "male" ? 0 : rider.gender == "female" ? 1 : 2
//
//        NSLayoutConstraint.activate([
//            genderSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            genderSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            genderSegmentedControl.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 20),
//            genderSegmentedControl.heightAnchor.constraint(equalToConstant: 40)
//
//        ])
//
//        setupTextField(addressTextField, placeholder: "Your Address")
//        addressTextField.text = rider.address
//
//        setupButton(logoutButton, title: "Log out", titleColor: .blue)
//        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
//
//        contentView.addSubview(logoutButton)
//
//
//        NSLayoutConstraint.activate([
//            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),   logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -290),
//            logoutButton.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 30),
//            logoutButton.heightAnchor.constraint(equalToConstant: 40)
//        ])
//
//             // Setup Delete Account Button
//        setupButton(deleteAccountButton, title: "Delete my account", titleColor: .red)
//        deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonTapped), for: .touchUpInside)
//        contentView.addSubview(deleteAccountButton)
//
//
//
//        NSLayoutConstraint.activate([
//
//            deleteAccountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            deleteAccountButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -200),
//            deleteAccountButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 1),
//            deleteAccountButton.heightAnchor.constraint(equalToConstant: 20)
//        ])
//
//
//    }
//
//
//
//
//
//
//    func setupTextField(_ textField: UITextField, placeholder: String, isEnabled: Bool = true) {
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.borderStyle = .roundedRect
//        textField.placeholder = placeholder
//        textField.isEnabled = isEnabled
//        contentView.addSubview(textField)
//
//        let previousView = contentView.subviews[contentView.subviews.count - 2]
//        NSLayoutConstraint.activate([
//            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            textField.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
//            textField.heightAnchor.constraint(equalToConstant: 40)
//        ])
//    }
//
//    func setupButton(_ button: UIButton, title: String, titleColor: UIColor) {
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle(title, for: .normal)
//        button.setTitleColor(titleColor, for: .normal)
//        contentView.addSubview(button)
//
//        let previousView = contentView.subviews[contentView.subviews.count - 2]
//        NSLayoutConstraint.activate([
//            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            button.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
//            button.heightAnchor.constraint(equalToConstant: 40)
//        ])
//    }
//
//    func populateData() {
//        if let address = rider.media?.address {
//            let url = URL(string: Config.Backend + address.replacingOccurrences(of: " ", with: "%20"))
//            ImageDownloader.default.downloadImage(with: url!, completionHandler: { result in
//                switch result {
//                case .success(let value):
//                    self.profileImageView.image = value.image
//                case .failure(let error):
//                    print(error)
//                }
//            })
//        }
//    }
//
//    @objc func uploadButtonTapped() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary
//        present(imagePicker, animated: true, completion: nil)
//    }
//
//    @objc func onSaveProfileClicked() {
//        rider.email = emailTextField.text
//        rider.firstName = firstNameTextField.text
//        rider.lastName = lastNameTextField.text
//        rider.gender = genderSegmentedControl.titleForSegment(at: genderSegmentedControl.selectedSegmentIndex)?.lowercased()
//        rider.address = addressTextField.text
//
//        UpdateProfile(user: self.rider).execute() { result in
//            switch result {
//            case .success(_):
//                UserDefaultsConfig.user = try! self.rider.asDictionary()
//                self.navigationController?.popViewController(animated: true)
//            case .failure(let error):
//                error.showAlert()
//            }
//        }
//    }
//
//    @objc func logoutButtonTapped() {
//
//    }
//
//
//    @objc func deleteAccountButtonTapped() {
//
//    }
//
//    // UIImagePickerControllerDelegate Methods
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let selectedImage = info[.originalImage] as? UIImage {
//            profileImageView.image = selectedImage
//
//            let data = selectedImage.jpegData(compressionQuality: 0.7)
//            UpdateProfileImage(data: data!).execute() { result in
//                switch result {
//                case .success(let response):
//                    SPAlert.present(title: "Profile image updated", preset: .done)
//                    self.rider.media = response
//                    UserDefaultsConfig.user = try! self.rider.asDictionary()
//                case .failure(let error):
//                    error.showAlert()
//                }
//            }
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//}
//import UIKit
//import SPAlert
//import Kingfisher

//class RiderEditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    let scrollView = UIScrollView()
//    let contentView = UIView()
//
//    let profileImageView = UIImageView()
//    let uploadButton = UIButton()
//    let mobileNumberTextField = UITextField()
//    let emailTextField = UITextField()
//    let firstNameTextField = UITextField()
//    let lastNameTextField = UITextField()
//    let genderSegmentedControl = UISegmentedControl(items: ["Male", "Female", "Transgender"])
//    let addressTextField = UITextField()
//    let saveButton = UIBarButtonItem()
//    let logoutButton = UIButton()
//    let deleteAccountButton = UIButton()
//
//    var rider: Rider!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        rider = try! Rider(from: UserDefaultsConfig.user!)
//        setupUI()
//        populateData()
//    }
//
//    func setupUI() {
//        view.backgroundColor = .white
//        title = "Your Account"
//
//        saveButton.title = "SAVE"
//        saveButton.style = .done
//        saveButton.target = self
//        saveButton.action = #selector(onSaveProfileClicked)
//        navigationItem.rightBarButtonItem = saveButton
//
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
//        ])
//
//        profileImageView.translatesAutoresizingMaskIntoConstraints = false
//        profileImageView.layer.cornerRadius = 50
//        profileImageView.clipsToBounds = true
//        profileImageView.contentMode = .scaleAspectFill
//        profileImageView.isUserInteractionEnabled = true
//        contentView.addSubview(profileImageView)
//
//        NSLayoutConstraint.activate([
//            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            profileImageView.widthAnchor.constraint(equalToConstant: 100),
//            profileImageView.heightAnchor.constraint(equalToConstant: 100)
//        ])
//
//        uploadButton.translatesAutoresizingMaskIntoConstraints = false
//        uploadButton.setImage(UIImage(systemName: "icloud.and.arrow.up.fill"), for: .normal)
//        uploadButton.backgroundColor = UIColor(named: "ThemeYellow")
//        uploadButton.tintColor = .black
//        uploadButton.layer.cornerRadius = 20
//        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
//        uploadButton.isUserInteractionEnabled = true
//        contentView.addSubview(uploadButton)
//
//        NSLayoutConstraint.activate([
//            uploadButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
//            uploadButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
//            uploadButton.widthAnchor.constraint(equalToConstant: 40),
//            uploadButton.heightAnchor.constraint(equalToConstant: 40)
//        ])
//
//        setupTextField(mobileNumberTextField, placeholder: "Mobile Number", isEnabled: false)
//        mobileNumberTextField.text = String(rider.mobileNumber!)
//
//        setupTextField(emailTextField, placeholder: "E-Mail")
//        emailTextField.text = rider.email
//
//        setupTextField(firstNameTextField, placeholder: "First Name")
//        firstNameTextField.text = rider.firstName
//
//        setupTextField(lastNameTextField, placeholder: "Last Name")
//        lastNameTextField.text = rider.lastName
//
//        genderSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(genderSegmentedControl)
//
//        genderSegmentedControl.selectedSegmentIndex = rider.gender == "male" ? 0 : rider.gender == "female" ? 1 : 2
//
//        NSLayoutConstraint.activate([
//            genderSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            genderSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            genderSegmentedControl.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 20),
//            genderSegmentedControl.heightAnchor.constraint(equalToConstant: 40)
//        ])
//
//        setupTextField(addressTextField, placeholder: "Your Address")
//        addressTextField.text = rider.address
//
//        setupButton(logoutButton, title: "Log out", titleColor: .blue)
//        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
//
//        NSLayoutConstraint.activate([
//            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -290),
//            logoutButton.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 30),
//            logoutButton.heightAnchor.constraint(equalToConstant: 40)
//        ])
//
//        setupButton(deleteAccountButton, title: "Delete my account", titleColor: .red)
//        deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonTapped), for: .touchUpInside)
//
//        NSLayoutConstraint.activate([
//            deleteAccountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            deleteAccountButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -200),
//            deleteAccountButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 1),
//            deleteAccountButton.heightAnchor.constraint(equalToConstant: 20)
//        ])
//    }
//
//    func setupTextField(_ textField: UITextField, placeholder: String, isEnabled: Bool = true) {
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.borderStyle = .roundedRect
//        textField.placeholder = placeholder
//        textField.isEnabled = isEnabled
//        textField.isUserInteractionEnabled = true
//        contentView.addSubview(textField)
//
//        let previousView = contentView.subviews[contentView.subviews.count - 2]
//        NSLayoutConstraint.activate([
//            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            textField.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
//            textField.heightAnchor.constraint(equalToConstant: 40)
//        ])
//    }
//
//    func setupButton(_ button: UIButton, title: String, titleColor: UIColor) {
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle(title, for: .normal)
//        button.setTitleColor(titleColor, for: .normal)
//        button.isUserInteractionEnabled = true
//        contentView.addSubview(button)
//
//        let previousView = contentView.subviews[contentView.subviews.count - 2]
//        NSLayoutConstraint.activate([
//            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            button.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
//            button.heightAnchor.constraint(equalToConstant: 40)
//        ])
//    }
//
//    func populateData() {
//        if let address = rider.media?.address {
//            let url = URL(string: Config.Backend + address.replacingOccurrences(of: " ", with: "%20"))
//            ImageDownloader.default.downloadImage(with: url!, completionHandler: { result in
//                switch result {
//                case .success(let value):
//                    self.profileImageView.image = value.image
//                case .failure(let error):
//                    print(error)
//                }
//            })
//        }
//    }
//
//    @objc func uploadButtonTapped() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary
//        present(imagePicker, animated: true, completion: nil)
//    }
//
//    @objc func onSaveProfileClicked() {
//        rider.email = emailTextField.text
//        rider.firstName = firstNameTextField.text
//        rider.lastName = lastNameTextField.text
//        rider.gender = genderSegmentedControl.titleForSegment(at: genderSegmentedControl.selectedSegmentIndex)?.lowercased()
//        rider.address = addressTextField.text
//
//        UpdateProfile(user: self.rider).execute() { result in
//            switch result {
//            case .success(let response):
//               // UserDefaultsConfig.user = response
//                SPAlert.present(title: "Success", message: "Profile updated successfully", preset: .done)
//            case .failure(let error):
//                print(error)
//                SPAlert.present(title: "Error", message: error.localizedDescription, preset: .error)
//            }
//        }
//    }
//
//    @objc func logoutButtonTapped() {
//        UserDefaultsConfig.user = nil
//       // (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(spla())
//    }
//
//    @objc func deleteAccountButtonTapped() {
//        DeleteProfile().execute { result in
//            switch result {
//            case .success(_):
//                UserDefaultsConfig.user = nil
//                (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(LoginViewController())
//            case .failure(let error):
//                print(error)
//                SPAlert.present(title: "Error", message: error.localizedDescription, preset: .error)
//            }
//        }
//    }
//}
