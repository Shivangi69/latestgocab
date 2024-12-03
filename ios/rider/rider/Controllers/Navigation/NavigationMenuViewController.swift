//
//  NavigationMenuViewController.swift
//  Rider
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

import UIKit
import Kingfisher

class NavigationMenuViewController : MenuViewController {
    let kCellReuseIdentifier = "MenuCell"
    let menuItems = ["Main"]
    
    @IBOutlet weak var imageUser: UIImageView!
    
    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet weak var labelCredit: UILabel!
    
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
        let user = try! Rider(from: UserDefaultsConfig.user!)
        if let riderImage = user.media?.address {
            let processor = DownsamplingImageProcessor(size: imageUser.intrinsicContentSize) |> RoundCornerImageProcessor(cornerRadius: imageUser.intrinsicContentSize.width / 2)
            let url = URL(string: Config.Backend + riderImage.replacingOccurrences(of: " ", with: "%20"))
            imageUser.kf.setImage(with: url, placeholder: UIImage(named: "Nobody"), options: [
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
        labelName.text = "\(user.firstName == nil ? "" : user.firstName!) \(user.lastName == nil ? "" : user.lastName!)"
        labelCredit.text = "\(user.mobileNumber!)"
    }
    
    
    @IBAction func PrefferedAggenc(_ sender: Any) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PreferredAgenciesViewController") as? PreferredAgenciesViewController {
            (menuContainerViewController.contentViewControllers[0] as! UINavigationController).pushViewController(vc, animated: true)
            menuContainerViewController.hideSideMenu()
        }
    }
    
    
    @IBAction func onpaymentClicked(_ sender: Any) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentmethodViewController") as? PaymentmethodViewController {
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
    
    @IBAction func onProfileClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        menuContainerViewController.contentViewControllers[0].performSegue(withIdentifier: "showEditProfile", sender: nil)
        menuContainerViewController.hideSideMenu()
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
    
    @IBAction func onCouponsClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
            
        }
        menuContainerViewController.contentViewControllers[0].performSegue(withIdentifier: "showCoupons", sender: nil)
        print(menuContainerViewController.contentViewControllers)

        menuContainerViewController.hideSideMenu()
    }
    
    @IBAction func onPromotionsClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        menuContainerViewController.contentViewControllers[0].performSegue(withIdentifier: "showPromotions", sender: nil)
        menuContainerViewController.hideSideMenu()
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
    
    @IBAction func onFavoritesClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        menuContainerViewController.contentViewControllers[0].performSegue(withIdentifier: "showFavorites", sender: nil)
        menuContainerViewController.hideSideMenu()
    }
    
    @IBAction func onAboutClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        menuContainerViewController.contentViewControllers[0].performSegue(withIdentifier: "showAbout", sender: nil)
        menuContainerViewController.hideSideMenu()
    }
    
//    @IBAction func onExitClicked(_ sender: UIButton) {
//        guard let menuContainerViewController = self.menuContainerViewController else {
//            return
//        }
//
//        // Clear user defaults
//        if let bundle = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: bundle)
//        }
//
//        // Dismiss the current view controller
//        self.dismiss(animated: true) {
//            // Hide the side menu
//            menuContainerViewController.hideSideMenu()
//
//            // Navigate to Splash screen
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let controller = storyboard.instantiateViewController(withIdentifier: "SplashViewController")
//
//            if let navigationController = self.navigationController {
//                navigationController.setViewControllers([controller], animated: true)
//            } else {
//                self.present(controller, animated: true, completion: nil)
//            }
//        }
//    }
    @IBAction func onExitClicked(_ sender: UIButton) {
        // Clear user defaults
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
        let splashViewController = storyboard.instantiateViewController(withIdentifier: "SplashViewController")

        // Reset the root view controller of the window to the splash view controller
        let navigationController = UINavigationController(rootViewController: splashViewController)

        window.rootViewController = navigationController

//        window.rootViewController = splashViewController

        // Add a transition animation (optional)
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
    }


}
