//
//  DriverNavigationMenuViewController.swift
//  Driver
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

import UIKit
import Kingfisher
import SPAlert
import SocketIO

class DriverNavigationMenuViewController : MenuViewController {
    let kCellReuseIdentifier = "MenuCell"
    let menuItems = ["Main"]
    
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelBalance: UILabel!
    
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()
        imageUser.layer.cornerRadius = imageUser.frame.size.width / 2
        imageUser.clipsToBounds = true
        imageUser.layer.borderColor = UIColor.white.cgColor
        imageUser.layer.borderWidth = 3.0
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let driver = try! Driver(from: UserDefaultsConfig.user!)
        if let driverImage = driver.media?.address {
            let processor = DownsamplingImageProcessor(size: imageUser.intrinsicContentSize) |> RoundCornerImageProcessor(cornerRadius: imageUser.intrinsicContentSize.width / 2)
            let url = URL(string: Config.Backend + driverImage.replacingOccurrences(of: " ", with: "%20"))
            imageUser.kf.setImage(with: url, placeholder: UIImage(named: "Nobody"), options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage
            ], completionHandler:  { result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            })
        }
        labelName.text = "\(driver.firstName == nil ? "" : driver.firstName!) \(driver.lastName == nil ? "" : driver.lastName!)"
        labelBalance.text = "\(driver.mobileNumber!)"
    }
    
    @IBAction func onWithdrawClicked(_ sender: UIButton) {
        let title = NSLocalizedString("Request Payment", comment: "")
        let message = NSLocalizedString("By clicking on \"OK\" you are requesting to cash out your earnings into your bank account. Are you sure?", comment: "Asking user if is sure to request a payment")
        let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Message OK button"), style: .default) { action in
            RequestPayment().execute() { result in
                switch result {
                case .success(_):
                    SPAlert.present(title: NSLocalizedString("Done", comment: ""), message: NSLocalizedString("Request sent. Will be processed soon.", comment: ""), preset: .done)
                    
                case .failure(let error):
                    error.showAlert()
                    
                }
            }
        })
        
        dialog.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(dialog, animated: true)
    }
    
    
//    @IBAction func agencydetails(_ sender: UIButton) {
//        guard let menuContainerViewController = self.menuContainerViewController else {
//            return
//        }
//        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Agencydetails View Controller") as? AgencydetailsViewController {
//            (menuContainerViewController.contentViewControllers[0] as! UINavigationController).pushViewController(vc, animated: true)
//            menuContainerViewController.hideSideMenu()
//        }
//    }
    
    @IBAction func agencydetails(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Agency") as? AgencydetailsViewController {
            (menuContainerViewController.contentViewControllers[0] as! UINavigationController).pushViewController(vc, animated: true)
            menuContainerViewController.hideSideMenu()
        }
    }
    
    
    @IBAction func deletebutton(_ sender: UIButton) {
        showAgencyPopup()
    }
    
    @IBAction func onStatisticsTouched(_ sender: Any) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        if let vc = Bundle.main.loadNibNamed("EarningScreen", owner: self, options: nil)?.first as? EarningViewController {
        (menuContainerViewController.contentViewControllers[0] as! UINavigationController).pushViewController(vc, animated: true)
            menuContainerViewController.hideSideMenu()
        }
    }
    
    @IBAction func onTravelsClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TripHistory") as? TripHistoryCollectionViewController {
            (menuContainerViewController.contentViewControllers[0] as! UINavigationController).pushViewController(vc, animated: true)
            menuContainerViewController.hideSideMenu()
        }
    }
        
    @IBAction func onTransactionsClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Transactions") as? TransactionsCollectionViewController {
            (menuContainerViewController.contentViewControllers[0] as! UINavigationController).pushViewController(vc, animated: true)
            menuContainerViewController.hideSideMenu()
        }
    }
    
    @IBAction func onWalletClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Wallet") as? WalletViewController {
            (menuContainerViewController.contentViewControllers[0] as! UINavigationController).pushViewController(vc, animated: true)
            menuContainerViewController.hideSideMenu()
        }
    }
    
    @IBAction func onAboutClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        
        menuContainerViewController.contentViewControllers[0].performSegue(withIdentifier: "showAbout", sender: nil)
        menuContainerViewController.hideSideMenu()
    }
    
    
//    
//    @IBAction func agencydetails(_ sender: Any) {
//        guard let menuContainerViewController = self.menuContainerViewController else {
//            return
//        }
//        
//        if let vc = Bundle.main.loadNibNamed("AgencydetailsViewController", owner: self, options: nil)?.first as? AgencydetailsViewController {
//        (menuContainerViewController.contentViewControllers[0] as! UINavigationController).pushViewController(vc, animated: true)
//            menuContainerViewController.hideSideMenu()
//        }
//        
//    }
    
  
    
    
    @IBAction func onExitClicked(_ sender: UIButton) {
//        guard let menuContainerViewController = self.menuContainerViewController else {
//            return
//        }
//        if let bundle = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: bundle)
//            self.dismiss(animated: true, completion: nil)
//            menuContainerViewController.hideSideMenu()
//        }
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
            UserDefaults.standard.synchronize()
        }

        // Hide the side menu
        menuContainerViewController?.hideSideMenu()

        // Get a reference to the app's window
        guard let window = UIApplication.shared.keyWindow else {
            return
        }

        // Instantiate the splash view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let splashViewController = storyboard.instantiateViewController(withIdentifier: "SplashVC")

        // Reset the root view controller of the window to the splash view controller
        window.rootViewController = splashViewController

        // Add a transition animation (optional)
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
        
    }
    
    
    func showAgencyPopup() {
        
        let alert = UIAlertController(title: "Agency Info", message: "This is your agency popup. Triggered from button or socket.", preferredStyle: .alert)
        
        // OK Button ke liye handler diya gaya hai
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.saveDriverRow(id: 126, agencyId: "27")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // OK button press hone par ye function chalega
  
    
    public func saveDriverRow(id: Int, agencyId: String) {
        let params: [Any] = [
            "saveRow",
            [
                "table": "Driver",
                "row": [
                    "id": id,
                    "status": "blocked",
                    "agencyId": agencyId
                ]
            ]
        ]
        
        SocketNetworkDispatcher.instance.dispatchnew(event: "saveRow", params: params) { result in
            switch result {
            case .success(let response):
                print("Driver row saved successfully: \(response)")
            //    completion(.success(response as! String)) // Return response
            case .failure(let error):
                print("Error saving driver row: \(error.localizedDescription)")
              //  completion(.failure(error)) // Return error
            }
        }
    }
    
}
