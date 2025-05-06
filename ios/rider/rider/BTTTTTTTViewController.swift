//
//  BTTTTTTTViewController.swift
//  rider
//
//  Created by Rohit wadhwa on 16/10/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit
import BottomSheet
import BottomSheetUtils
import MapKit
import SPAlert

class BTTTTTTTViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, CouponsViewDelegate {
@IBOutlet weak var custumeuiview: UIView!

@IBOutlet weak var tableView: UITableView!
public var calculateFareResult: CalculateFareResult!
public var callback: ServiceRequested?
private var selectedCategory: ServiceCategory?
private var selectedService: Service?
    var pointsAnnotations: [MKPointAnnotation] = []

@IBOutlet weak var viewBlur: UIView!

@IBOutlet weak var myButton: UIButton!

// Sample data model

//    init(calculateFareResult: CalculateFareResult, callback: ServiceRequested?) {
//          self.calculateFareResult = calculateFareResult
//          self.callback = callback
//          super.init(nibName: nil, bundle: nil)
//      }
//
//      required init?(coder: NSCoder) {
//          super.init(coder: coder)
//      }
    
override func viewDidLoad() {
    super.viewDidLoad()
    self.calculateFareResult = SharedData.shared.calculateFareResult
    self.callback = SharedData.shared.callback
    print(calculateFareResult!)
    self.pointsAnnotations = SharedData.shared.MapAnotation ?? []

    myButton.layer.cornerRadius = 10
    myButton.clipsToBounds = true
    
    myButton.setTitle("SELECT GO MINIVANS", for: .normal)
    myButton.isEnabled = false
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UINib(nibName: "BTTableViewCell", bundle: nil), forCellReuseIdentifier: "BTTableViewCell")
    
    let screenHeight = UIScreen.main.bounds.height
      let initialY = screenHeight / 2
    custumeuiview.frame = CGRect(x: 0, y: initialY, width: self.view.bounds.width, height: screenHeight)
    custumeuiview.layer.cornerRadius = 20
    custumeuiview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    custumeuiview.layer.masksToBounds = true
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    custumeuiview.addGestureRecognizer(panGesture)

}

    func didSelectedCoupon(_ coupon: Coupon) {
        let locs = pointsAnnotations.map { return $0.coordinate }

        CalculateFareAfterCoupon(code: coupon.code!, locations: locs).execute { result in
            switch result {
            case .success(let calculateFareAfterCouponResult):
                print("result", calculateFareAfterCouponResult)
                
                // Update the current fare result with the new data
                self.calculateFareResult = CalculateFareResult(
                    categories: calculateFareAfterCouponResult.categories,
                    distance: calculateFareAfterCouponResult.distance,
                    duration: calculateFareAfterCouponResult.duration,
                    currency: calculateFareAfterCouponResult.currency
                )
                
                
                UserDefaults.standard.set(coupon.code, forKey: "couponcode")
    
                print(coupon.code , "dfdfvfdvfdv")
                
                SPAlert.present(title: "Coupon Applied", preset: .done)
                
                // Refresh the table view to display the updated costs
                self.tableView.reloadData()
                
            case .failure(let error):
                print("error", error)
                error.showAlert()
            }
        }
    }

@objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    guard let view = gesture.view else { return }

    let translation = gesture.translation(in: view.superview)
    let screenHeight = UIScreen.main.bounds.height
    let bottomSheetMinY = screenHeight / 2
    let bottomSheetMaxY = screenHeight - view.bounds.height

    switch gesture.state {
    case .changed:
        // Restrict the dragging within the allowed min and max positions
        let newY = view.frame.minY + translation.y
        if newY >= bottomSheetMaxY && newY <= bottomSheetMinY {
            view.frame.origin.y = newY
            gesture.setTranslation(.zero, in: view.superview)
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

        let category = calculateFareResult.categories[indexPath.section]
        let service = category.services[indexPath.row]
        
        // Update title
        cell.textTitle.text = service.title
        let actual = service.cost ?? 0.0
        let discount = service.estimatedCostAfterCoupon
        
        // Format the actual cost
        let actualCostText = "₹ \(String(format: "%.2f", Double(actual)))"
        
        if discount == 0 {
            // If discount is 0, show only the actual cost without strikethrough
            cell.actualcost.text = actualCostText
            cell.discountcost.text = ""
        } else {
            // Show actual cost with strikethrough and display the discounted cost
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: actualCostText)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.actualcost.attributedText = attributeString
            
            // Show discounted cost
            let discountCostText = "₹ \(String(format: "%.2f", Double(discount)))"
            cell.discountcost.text = discountCostText
        }

        // Update other fields (image, etc.)
        cell.pplcount.text = service.seatingCapacity != nil ? "\(service.seatingCapacity!)" : ""
//        pplcount.text = service.seatingCapacity != nil ? "₹\(service.seatingCapacity!)" : ""

        if let media = service.media, let address = media.address {
            let url = URL(string: Config.Backend + address)
            cell.imageIcon.kf.setImage(with: url)
        } else {
            cell.imageIcon.image = UIImage(named: "placeholder")
        }

        return cell
    }
@IBAction func onCouponsClicked(_ sender: UIButton) {
    // Instantiate the view controller from the storyboard
    
     var fromwhere = "BTVC"
    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CouponsCollectionViewController") as? CouponsCollectionViewController {
        vc.selectMode = true
        vc.delegate = self
        vc.fromwhere = "BTVC"
        vc.pointsAnnotations = pointsAnnotations
        if let navController = self.navigationController {
            navController.pushViewController(vc, animated: true )
        } else {
            self.present(vc, animated: true, completion: nil)
            print("Presented modally as navigationController is nil.")
        }
    } else {
        print("Could not instantiate view controller with identifier 'CouponsCollectionViewController'.")
    }
}

@IBAction func ridenow(_ sender: UIButton) {
    dismiss(animated: true) {
        if let d = self.callback {
            d.RideNowSelected(service: self.selectedService!)
            
        }
    }
}

@IBAction func onselectionClicked(_ sender: UIButton) {
    // Dismiss the current view controller
    dismiss(animated: true) {
        // Post a notification to trigger goBackFromServiceSelection() after the view is dismissed
        NotificationCenter.default.post(name: Notification.Name("goBackFromServiceSelectionNotification"), object: nil)
        UserDefaults.standard.removeObject(forKey: "couponcode")
    }
}
    

func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return calculateFareResult.categories.description
    
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let category = calculateFareResult.categories[indexPath.section]
       selectedService = category.services[indexPath.row]
       
       print("Selected Service: \(selectedService!.title ?? "")")
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = .lightGray
    
    
        myButton.isEnabled = true
        myButton.backgroundColor = UIColor(named: "ThemeYellow")
        myButton.setTitleColor(.black, for: .normal)
        myButton.setTitle("Request \(selectedService!.title ?? "") Now", for: .normal)

   }


func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
    // Reset the background color when deselecting a cell
    if let cell = tableView.cellForRow(at: indexPath) as? BTTableViewCell {
        cell.contentView.backgroundColor = UIColor.clear // Reset the background color
    }
    return indexPath
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


