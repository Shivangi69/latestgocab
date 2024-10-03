//
//  BTViewController.swift
//  rider
//
//  Created by Rohit wadhwa on 27/09/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit
import BottomSheet
import BottomSheetUtils
 
class BTViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var custumeuiview: UIView!

    @IBOutlet weak var tableView: UITableView!
    public var calculateFareResult: CalculateFareResult!
    public var callback: ServiceRequested?
    private var selectedCategory: ServiceCategory?
    private var selectedService: Service?
    
    @IBOutlet weak var buttonRideNow: ColoredButton!
    @IBOutlet weak var buttonRideLater: ColoredButton!
    @IBOutlet weak var tabBar: UISegmentedControl!
    @IBOutlet weak var collectionServices: UICollectionView!
    @IBOutlet weak var viewBlur: UIView!
    
    @IBOutlet weak var myButton: UIButton!

    // Sample data model
    var data: [[String]] = [
        ["Row 1", "Row 2", "Row 3"], // Section 1
        ["Row 1", "Row 2"],          // Section 2
        ["Row 1", "Row 2", "Row 3", "Row 4"], // Section 3
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(calculateFareResult!)

        
        // Assuming the button is connected via an IBOutlet
        myButton.layer.cornerRadius = 10
        myButton.clipsToBounds = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "BTTableViewCell", bundle: nil), forCellReuseIdentifier: "BTTableViewCell")
        
        
        
        custumeuiview.layer.cornerRadius = 20 // Adjust the corner radius value as needed
          custumeuiview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top-left and top-right corners
          custumeuiview.layer.masksToBounds = true // Ensure that the corner radius is applied

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
               custumeuiview.addGestureRecognizer(panGesture)
        
        
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
           guard let view = gesture.view else { return }

           let translation = gesture.translation(in: view.superview)
           let velocity = gesture.velocity(in: view.superview)

           switch gesture.state {
           case .began:
               // Optional: Do something when the gesture begins
               break

           case .changed:
               // Move the view based on the drag
               view.center.y += translation.y
               gesture.setTranslation(.zero, in: view.superview)

           case .ended:
               // Determine if the bottom sheet should be dismissed or not based on the velocity
               if velocity.y > 500 { // Adjust this threshold as needed
                   dismiss(animated: true, completion: nil)
               } else {
                   // Snap back to original position if not dismissed
                   UIView.animate(withDuration: 0.3) {
                       view.center.y = view.superview!.bounds.height - view.bounds.height / 2
                   }
               }

           default:
               break
           }
       }
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return calculateFareResult.categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = calculateFareResult.categories[section]
            return category.services.count    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BTTableViewCell", for: indexPath) as! BTTableViewCell
        //cell.initialize(service: (selectedCategory?.services[indexPath.row])!, distance: self.calculateFareResult.distance, duration: self.calculateFareResult.duration, currency: self.calculateFareResult.currency)
        let category = calculateFareResult.categories[indexPath.section]
            let service = category.services[indexPath.row]
          
        cell.textTitle.text = service.title
        
        let actual = service.baseFare
        let offdic = service.cost

        let cost = service.cost
        
        // Safely unwrap and convert the actual cost and discount cost to String
        if let actual = service.baseFare {
            cell.actualcost.text = String(actual) // Convert to String
        } else {
            cell.actualcost.text = "" // Set to an empty string if nil
        }
        
        if let offdic = service.cost {
            cell.discountcost.text = String(offdic) // Convert to String
        } else {
            cell.discountcost.text = "" // Set to an empty string if nil
        }
        cell.pplcount.text = String(service.maxQuantity)
        if let media = service.media, let address = media.address {
             let url = URL(string: Config.Backend + address)
             cell.imageIcon.kf.setImage(with: url)
         } else {
             cell.imageIcon.image = UIImage(named: "placeholder") // Default placeholder image
         }
        

        return cell
    }

    
    
    @IBAction func onCouponsClicked(_ sender: UIButton) {
        // Instantiate the view controller from the storyboard
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CouponsCollectionViewController") as? CouponsCollectionViewController {
            vc.selectMode = true
            
            // Check if navigationController is available before pushing the view controller
            if let navController = self.navigationController {
                navController.pushViewController(vc, animated: true)
            } else {
                // If navigationController is nil, you can present the view controller modally
                self.present(vc, animated: true, completion: nil)
                print("Presented modally as navigationController is nil.")
            }
        } else {
            print("Could not instantiate view controller with identifier 'CouponsCollectionViewController'.")
        }
    }

    
    @IBAction func onselectionClicked(_ sender: UIButton) {
        // Dismiss the current view controller
        dismiss(animated: true) {
            // Post a notification to trigger goBackFromServiceSelection() after the view is dismissed
            NotificationCenter.default.post(name: Notification.Name("goBackFromServiceSelectionNotification"), object: nil)
        }
    }
        
        
//    func goBackFromServiceSelection() {
//        LoadingOverlay.shared.hideOverlayView()
//        leftBarButton.image = UIImage(named: "menu")
//        map.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        map.removeAnnotations(map.annotations)
//        map.removeOverlays(map.overlays)
//        AddmoreDesButton.isEnabled = false
//        AddMore = false
//        pointsAnnotations.removeAll()
//        buttonAddDestination.isHidden = true
//        buttonConfirmFinalDestination.isHidden = true
////        buttonConfirmPickup.isHidden = false
//        buttonFavorites.isEnabled = true
//        self.containerServices.isHidden = true
//        self.pinAnnotation.isHidden = false
//        map.isUserInteractionEnabled = true
//        FromLoc = "pickUp"
//        self.DropTextfeild.text = ""
//        self.locationManager.startUpdatingLocation()
//        PikupView.isUserInteractionEnabled = true
//        dropview.isUserInteractionEnabled = true
//
//    }

    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return calculateFareResult.categories.description
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create a UIView to hold the header
        
        
        let category = calculateFareResult.categories[section]
            
            // Return the category name as the header title
          
        let headerView = UIView()
        headerView.backgroundColor = .lightbordergray // Set the background color of the section header
        // Create a UILabel for the header title
        
        let headerLabel = UILabel()
        headerLabel.text = category.title //"Section \(section + 1)" // Set your section title
        headerLabel.textColor = .black // Set the text color to gray
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16) // Set font style and size
        headerLabel.frame = CGRect(x: 16, y: 5, width: tableView.frame.width - 32, height: 25) // Position the label within the view
        // Add the label to the header view
        headerView.addSubview(headerLabel)

        return headerView
    }
    
}

extension UIColor {
    static let lightbordergray = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1) // Very light gray
}


