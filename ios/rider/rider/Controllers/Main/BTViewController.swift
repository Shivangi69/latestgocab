//
//  BTViewController.swift
//  rider
//
//  Created by Rohit wadhwa on 27/09/24.
//  Copyright © 2024 minimal. All rights reserved.


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
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
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
          
        cell.textTitle.text = service.title
        
        let actual = service.baseFare
        let offdic = service.cost
        let cost = service.cost
        
        
        if let actual = service.baseFare {
            cell.actualcost.text = "₹ \(String(format: "%.2f", actual))"
        } else {
            cell.actualcost.text = ""
        }

        print(service , " serviceprint%%%")
        if let offdic = service.cost {
            cell.discountcost.text = "₹ \(String(format: "%.2f", offdic))"
        } else {
            cell.discountcost.text = ""
        }
        

        if let pltcnt = service.seatingCapacity {
            cell.discountcost.text = String(pltcnt)
        } else {
            cell.discountcost.text = ""
        }

        
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
//
//extension UIColor {
//    static let lightbordergray = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1) // Very light gray
//}
//
//
