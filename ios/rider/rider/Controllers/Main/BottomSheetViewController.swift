////import UIKit
////import MapKit
////
////class BottomSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
////    var pickupLocation: CLLocationCoordinate2D?
////    var dropLocations: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
////    var mapView: MKMapView?
////
////    @IBOutlet weak var tableView: UITableView!
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        tableView.delegate = self
////        tableView.dataSource = self
////        tableView.register(UINib(nibName: "PickupLocationCell", bundle: nil), forCellReuseIdentifier: "PickupLocationCell")
////        tableView.register(UINib(nibName: "DropLocationCell", bundle: nil), forCellReuseIdentifier: "DropLocationCell")
////        tableView.layer.cornerRadius = 20
////
////       // tableView.dropShadow()
////    }
////
////    @IBAction func addButtonTapped(_ sender: UIButton) {
////        addDropLocation()
////    }
////
////    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        // Include 1 for pickup location
////        return 1 + dropLocations.count
////    }
////
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        if indexPath.row == 0 {
////            // Pickup Location Cell
////            let cell = tableView.dequeueReusableCell(withIdentifier: "PickupLocationCell", for: indexPath) as! PickupLocationCell
////            cell.pickupLocationTextField.text = pickupLocation == nil ? "Set Pickup Location" : "Pickup Location" // Replace with actual address or description
//////            cell.onPickupButtonTapped = { [weak self] in
//////                self?.setPickupLocation()
//////            }
////            return cell
////        } else {
////            // Drop Location Cell
////            let cell = tableView.dequeueReusableCell(withIdentifier: "DropLocationCell", for: indexPath) as! DropLocationCell
////            let dropLocationIndex = indexPath.row - 1
////            cell.dropLocationTextField.placeholder = "Drop Location \(dropLocationIndex + 1)" // Replace with actual address or description
////           // cell.addButton.isHidden = dropLocationIndex != dropLocations.count - 1 || dropLocations.count >= 7
////            cell.deleteButton.isHidden = dropLocations.count <= 1
////
//////            cell.onAddButtonTapped = { [weak self] in
//////                self?.addDropLocation()
//////            }
////
////            cell.onDeleteButtonTapped = { [weak self] in
////                self?.removeDropLocation(at: dropLocationIndex)
////            }
////
////            return cell
////        }
////    }
////
////    func setPickupLocation() {
////        // Open place picker and set the pickup location
////        pickupLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0) // Replace with actual location
////        tableView.reloadData()
////    }
////
////    func addDropLocation() {
////        // Open place picker and add a new drop location
////        let newDropLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0) // Replace with actual location
////        dropLocations.append(newDropLocation)
////
////        NotificationCenter.default.post(name:  Notification.Name("Increaseheight"), object: nil)
////        tableView.reloadData()
////    }
////
////    func removeDropLocation(at index: Int) {
////        dropLocations.remove(at: index)
////        if dropLocations.isEmpty {
////            // Ensure at least one drop location is shown
////            dropLocations.append(CLLocationCoordinate2D(latitude: 0, longitude: 0))
////        }
////        NotificationCenter.default.post(name:  Notification.Name("Decreaseheight"), object: nil)
////        tableView.reloadData()
////    }
////
////    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
////        return indexPath.row > 0
////    }
////
//////    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//////        if editingStyle == .delete {
//////            removeDropLocation(at: indexPath.row - 1)
//////        }
//////    }
////}
import UIKit
import MapKit
import GooglePlaces
import GooglePlacesPicker
import PlacesPicker
//class BottomSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GMSAutocompleteViewControllerDelegate {
//    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//        print("Place name: \(place)")
////        if(FromLoc == "pickUp"){
////            PickuPtextfeild.text = "\(place.formattedAddress ?? "")"
////
////        }
////      else  if(FromLoc == "Drop"){
////            DropTextfeild.text = "\(place.formattedAddress ?? "")"
////        }
////        self.map.setCenter(place.coordinate, animated: true)
//        dropLocationsStr.add(place.formattedAddress ?? "")
//
//        let ann = MKPointAnnotation()
//        ann.coordinate = place.coordinate
//        ann.title = place.formattedAddress
//
//        pointsAnnotations.append(ann)
//        let newDropLocation = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude) // Replace with actual location
//        dropLocations.append(newDropLocation)
//        NotificationCenter.default.post(name: Notification.Name("Increaseheight"), object: nil)
//        tableView.reloadData()
//        dismiss(animated: true, completion: nil)
//      }
//
//      func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
//        // TODO: handle the error.
//        print("Error: \(error)")
//        dismiss(animated: true, completion: nil)
//      }
//
//      // User cancelled the operation.
//      func wasCancelled(_ viewController: GMSAutocompleteViewController) {
//        print("Autocomplete was cancelled.")
//        dismiss(animated: true, completion: nil)
//      }
//
//
//
//    var pickupLocation: CLLocationCoordinate2D?
//    var dropLocations: [CLLocationCoordinate2D] = []
//    var mapView: MKMapView?
//    var pickupLocationstr: String?
//    var dropLocationsStr =  NSMutableArray()
//
//
//    var pointsAnnotations: [MKPointAnnotation] = []
//
//    @IBOutlet weak var tableView: UITableView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UINib(nibName: "PickupLocationCell", bundle: nil), forCellReuseIdentifier: "PickupLocationCell")
//        tableView.register(UINib(nibName: "DropLocationCell", bundle: nil), forCellReuseIdentifier: "DropLocationCell")
//        tableView.layer.cornerRadius = 20
//
//        if dropLocations.isEmpty {
//            dropLocations.append(CLLocationCoordinate2D(latitude: 0, longitude: 0))
//        }
//        print(dropLocationsStr)
//    }
//    @IBAction func CalllDone(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//
//        NotificationCenter.default.post(name: Notification.Name("CallDone"), object: pointsAnnotations)
//
//
//    }
//
//    @IBAction func addButtonTapped(_ sender: UIButton) {
//        addDropLocation()
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // Include 1 for pickup location and 1 for the add button if less than 7 drop locations
//        return 1 + dropLocations.count + (dropLocations.count < 7 ? 1 : 0)
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            // Pickup Location Cell
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PickupLocationCell", for: indexPath) as! PickupLocationCell
//            cell.pickupLocationTextField.text = pickupLocation == nil ? "Set Pickup Location" :pickupLocationstr  // Replace with actual address or description
//
//            return cell
//        } else if indexPath.row == dropLocations.count + 1 {
//            // Add Button Cell
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PickupLocationCell", for: indexPath) as! PickupLocationCell
//            cell.pickupLocationTextField.text = ""
//            cell.pickupLocationTextField.placeholder = "Add Stop"
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addDropLocation))
//            cell.pickupLocationTextField.isUserInteractionEnabled = true
//            cell.pickupLocationTextField.addGestureRecognizer(tapGesture)
//            // Add button action here if needed
//            return cell
//        } else {
//            // Drop Location Cell
//            let cell = tableView.dequeueReusableCell(withIdentifier: "DropLocationCell", for: indexPath) as! DropLocationCell
//            let dropLocationIndex = indexPath.row - 1
//            cell.dropLocationTextField.placeholder = "Drop Location \(dropLocationIndex + 1)" // Replace with actual address or description//dropLocationsStr?[indexPath.row]
//            cell.deleteButton.isHidden = dropLocations.count <= 1
//            cell.dropLocationTextField.text = dropLocationsStr[dropLocationIndex] as? String
//            cell.onDeleteButtonTapped = { [weak self] in
//                self?.removeDropLocation(at: dropLocationIndex)
//            }
//
//            return cell
//        }
//    }
//
//    func setPickupLocation() {
//        // Open place picker and set the pickup location
//        pickupLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0) // Replace with actual location
//        tableView.reloadData()
//    }
//
//    @objc  func addDropLocation() {
//        // Open place picker and add a new drop location
////        let newDropLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0) // Replace with actual location
////        dropLocations.append(newDropLocation)
////        NotificationCenter.default.post(name: Notification.Name("Increaseheight"), object: nil)
////        tableView.reloadData()
//
//        let autocompleteController = GMSAutocompleteViewController()
//            autocompleteController.delegate = self
//
//            // Specify the place data types to return.
//            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
//                                                      UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.coordinate.rawValue)  | UInt(GMSPlaceField.formattedAddress.rawValue) |  UInt(GMSPlaceField.defaultFields.rawValue))!
//            autocompleteController.placeFields = fields
//
//            present(autocompleteController, animated: true, completion: nil)
//    }
//
//    func removeDropLocation(at index: Int) {
//        dropLocations.remove(at: index)
//        pointsAnnotations.remove(at: index+1)
//        dropLocationsStr.removeObject(at: index)
//        if dropLocations.isEmpty {
//            // Ensure at least one drop location is shown
//            dropLocations.append(CLLocationCoordinate2D(latitude: 0, longitude: 0))
//        }
//        NotificationCenter.default.post(name: Notification.Name("Decreaseheight"), object: nil)
//        tableView.reloadData()
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return indexPath.row > 0 && indexPath.row <= dropLocations.count
//    }
//}

import UIKit
import MapKit
import GooglePlaces

class BottomSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GMSAutocompleteViewControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Address.lastDownloaded.count;
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Address.lastDownloaded[row].title;
    }

    var pickupLocation: CLLocationCoordinate2D?
    var dropLocations: [CLLocationCoordinate2D] = []
    var mapView: MKMapView?
    var pickupLocationstr: String?
    var dropLocationsStr = NSMutableArray()
    var pointsAnnotations: [MKPointAnnotation] = []
    var editingIndexPath: IndexPath?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PickupLocationCell", bundle: nil), forCellReuseIdentifier: "PickupLocationCell")
        tableView.register(UINib(nibName: "DropLocationCell", bundle: nil), forCellReuseIdentifier: "DropLocationCell")
        tableView.layer.cornerRadius = 20
        
        if dropLocations.isEmpty {
            dropLocations.append(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        }
        print(dropLocationsStr)
        tableView.isEditing = true

    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            // Allow reordering for all cells except the "Add Stop" cell
            return indexPath.row != dropLocations.count + 1
        }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Ensure the "Add Stop" cell stays at the last index
        if destinationIndexPath.row > dropLocations.count {
            DispatchQueue.main.async {
                tableView.moveRow(at: destinationIndexPath, to: sourceIndexPath)
            }
            return
        }

        // Ensure the pickup location remains in its place
        if sourceIndexPath.row == 0 || destinationIndexPath.row == 0 {
            DispatchQueue.main.async {
                tableView.moveRow(at: destinationIndexPath, to: sourceIndexPath)
            }
            return
        }

        let sourceIndex = sourceIndexPath.row - 1
        let destinationIndex = destinationIndexPath.row - 1

        // Update data source for drop locations
        let movedDropLocation = dropLocations.remove(at: sourceIndex)
        dropLocations.insert(movedDropLocation, at: destinationIndex)

        // Update data source for drop locations' strings
        let movedDropLocationStr = dropLocationsStr[sourceIndex]
        dropLocationsStr.removeObject(at: sourceIndex)
        dropLocationsStr.insert(movedDropLocationStr, at: destinationIndex)

        // Update data source for annotations
        let movedAnnotation = pointsAnnotations.remove(at: sourceIndex + 1)
        pointsAnnotations.insert(movedAnnotation, at: destinationIndex + 1)
    }

    @IBAction func CalllDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("CallDone"), object: pointsAnnotations)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        addDropLocation()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Include 1 for pickup location and 1 for the add button if less than 7 drop locations
        return 1 + dropLocations.count + (dropLocations.count < 7 ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Pickup Location Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "PickupLocationCell", for: indexPath) as! PickupLocationCell
            cell.pickupLocationTextField.text = pickupLocation == nil ? "Set Pickup Location" : pickupLocationstr
            cell.pickupLocationTextField.delegate = self
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openAutocompleteForPickupLocation))
            cell.pickupLocationTextField.isUserInteractionEnabled = true
            cell.pickupLocationTextField.addGestureRecognizer(tapGesture)
            cell.startbutton.setTitle("", for: .normal)


            cell.onsaveButtonTapped = { [weak self] in
                self?.openFavuoraite(at: indexPath.row)
            }

            return cell
        } else if indexPath.row == dropLocations.count + 1 {
            // Add Button Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "PickupLocationCell", for: indexPath) as! PickupLocationCell
            cell.pickupLocationTextField.text = ""
            cell.pickupLocationTextField.placeholder = "Add Stop"
            cell.pickupLocationTextField.delegate = self

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addDropLocation))
            cell.pickupLocationTextField.isUserInteractionEnabled = true
            cell.startbutton.setTitle("", for: .normal)
            cell.onsaveButtonTapped = { [weak self] in
                self?.openFavuoraite(at: indexPath.row)
            }
            cell.pickupLocationTextField.addGestureRecognizer(tapGesture)
            return cell
        } else {
            // Drop Location Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropLocationCell", for: indexPath) as! DropLocationCell
            let dropLocationIndex = indexPath.row - 1
            cell.dropLocationTextField.placeholder = "Drop Location \(dropLocationIndex + 1)" // Replace with actual address or description
            cell.deleteButton.isHidden = dropLocations.count <= 1
            cell.dropLocationTextField.text = dropLocationsStr[dropLocationIndex] as? String
            cell.dropLocationTextField.delegate = self
            cell.onsaveButtonTapped = { [weak self] in
                self?.openFavuoraite(at: indexPath.row)
            }
            cell.onDeleteButtonTapped = { [weak self] in
                self?.removeDropLocation(at: dropLocationIndex)
            }

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openAutocompleteForDropLocation(_:)))
            cell.dropLocationTextField.isUserInteractionEnabled = true
            cell.dropLocationTextField.addGestureRecognizer(tapGesture)
            cell.dropLocationTextField.tag = indexPath.row

            return cell
        }
    }

    @objc func openAutocompleteForPickupLocation() {
        editingIndexPath = IndexPath(row: 0, section: 0)
        openAutocompleteController()
    }

    @objc func openAutocompleteForDropLocation(_ sender: UITapGestureRecognizer) {
        if let tag = sender.view?.tag {
            editingIndexPath = IndexPath(row: tag, section: 0)
            openAutocompleteController()
        }
    }
    func openFavuoraite(at index: Int){
        GetAddresses().execute() { result in
            switch result {
            case .success(let response):
                if(response.count < 1) {
                    let alert = UIAlertController(title: NSLocalizedString("Message", comment: ""), message: NSLocalizedString("No Favorite Address found.", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Allright!", comment: ""), style: .default) { action in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    self.present(alert, animated: true)
                    return
                }
                Address.lastDownloaded = response
                let vc = UIViewController()
                vc.preferredContentSize = CGSize(width: 250,height: 150)
                let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 150))
                pickerView.delegate = self
                pickerView.dataSource = self
                vc.view.addSubview(pickerView)
                let dlg = UIAlertController(title: NSLocalizedString("Saved locations", comment: "Favorites Picker Title"), message: NSLocalizedString("Chose the location from below picker", comment: "Favorites Picker Description"), preferredStyle: .alert)
                dlg.setValue(vc, forKey: "contentViewController")
                dlg.addAction(UIAlertAction(title: "Done", style: .default){ action in
                    
                    
                    
                    let ann = MKPointAnnotation()
                    ann.coordinate = response[pickerView.selectedRow(inComponent: 0)].location!
                    ann.title = response[pickerView.selectedRow(inComponent: 0)].address!
                    
                    
                    
                    
                    
                    
                    
                    if index == 0 {
                        // Update pickup location
                        self.pickupLocation =  ann.coordinate
                        self.pickupLocationstr = ann.title
                        self.pointsAnnotations.remove(at: 0)
                        self.pointsAnnotations.insert(ann, at: 0)
                    }
                    else if index == self.dropLocations.count + 1 {
                        self.dropLocationsStr.add(ann.title  ?? "")
                        
                        
                        
                        self.pointsAnnotations.append(ann)
                        let newDropLocation = CLLocationCoordinate2D(latitude: ann.coordinate.latitude, longitude: ann.coordinate.longitude) // Replace with actual location
                        self.dropLocations.append(newDropLocation)
                        NotificationCenter.default.post(name: Notification.Name("Increaseheight"), object: nil)
                    }
                    else {
                        // Update drop location
                        let dropLocationIndex = index
                        self.dropLocations.remove(at: dropLocationIndex-1)
                        self.dropLocations.insert( ann.coordinate, at: dropLocationIndex-1)
                        self.dropLocationsStr.remove(dropLocationIndex-1)
                        self.dropLocationsStr.insert( ann.title ?? "", at: dropLocationIndex-1)
                        self.pointsAnnotations.remove(at: dropLocationIndex)
                        self.pointsAnnotations.insert(ann, at: dropLocationIndex)
                        
                        
                    }
                    self.tableView.reloadData()
                })
                dlg.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(dlg, animated: true)

            case .failure(let error):
                error.showAlert()
            }
        }
    }

    func openAutocompleteController() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.coordinate.rawValue)  | UInt(GMSPlaceField.formattedAddress.rawValue) |  UInt(GMSPlaceField.defaultFields.rawValue))!
        autocompleteController.placeFields = fields
        present(autocompleteController, animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if let indexPath = editingIndexPath {
            let annotation = MKPointAnnotation()
            annotation.coordinate = place.coordinate
            annotation.title = place.formattedAddress

            if indexPath.row == 0 {
                // Update pickup location
                pickupLocation = place.coordinate
                pickupLocationstr = place.formattedAddress
                pointsAnnotations.remove(at: 0)
                pointsAnnotations.insert(annotation, at: 0)
            }
            else if indexPath.row == dropLocations.count + 1 {
                dropLocationsStr.add(place.formattedAddress ?? "")

                let ann = MKPointAnnotation()
                ann.coordinate = place.coordinate
                ann.title = place.formattedAddress

                pointsAnnotations.append(ann)
                let newDropLocation = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude) // Replace with actual location
                dropLocations.append(newDropLocation)
                NotificationCenter.default.post(name: Notification.Name("Increaseheight"), object: nil)
//                tableView.reloadData()
//                dismiss(animated: true, completion: nil)
            }
            else {
                // Update drop location
                let dropLocationIndex = indexPath.row
                dropLocations.remove(at: dropLocationIndex-1)
                dropLocations.insert(place.coordinate, at: dropLocationIndex-1)
                dropLocationsStr.remove(dropLocationIndex-1)
                dropLocationsStr.insert( place.formattedAddress ?? "", at: dropLocationIndex-1)
                pointsAnnotations.remove(at: dropLocationIndex)
                pointsAnnotations.insert(annotation, at: dropLocationIndex)
//                if pointsAnnotations.count > dropLocationIndex + 1 {
//                    pointsAnnotations[dropLocationIndex + 1] = annotation
//                } else {
//                    pointsAnnotations.append(annotation)
//                }


            }
//            NotificationCenter.default.post(name: Notification.Name("Increaseheight"), object: nil)
            tableView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        //textField code

        textField.resignFirstResponder()  //if desired
        return true
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: \(error)")
        dismiss(animated: true, completion: nil)
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }

    @objc func addDropLocation() {
        editingIndexPath = IndexPath(row: dropLocations.count + 1, section: 0)
        openAutocompleteController()
    }

    func removeDropLocation(at index: Int) {
        dropLocations.remove(at: index)
        pointsAnnotations.remove(at: index + 1)
        dropLocationsStr.removeObject(at: index)
        if dropLocations.isEmpty {
            dropLocations.append(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        }
        NotificationCenter.default.post(name: Notification.Name("Decreaseheight"), object: nil)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row > 0 && indexPath.row <= dropLocations.count
    }
}
//extension BottomSheetViewController: UITableViewDragDelegate, UITableViewDropDelegate

extension BottomSheetViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        // Prevent dragging pickup location and add button cells
        guard indexPath.row != 0, indexPath.row != dropLocations.count + 1 else {
            return []
        }

        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: "\(indexPath.row)" as NSString))
        dragItem.localObject = dropLocations[indexPath.row - 1]
        return [dragItem]
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath

        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = tableView.numberOfRows(inSection: 0) - 1
            destinationIndexPath = IndexPath(row: row, section: 0)
        }

        // Ensure drop is not allowed on pickup location and add button cells
        guard destinationIndexPath.row != 0, destinationIndexPath.row != dropLocations.count + 1 else {
            return
        }

        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            guard let items = items as? [NSString], let itemString = items.first as? String, let sourceRow = Int(itemString) else { return }

            let sourceIndex = sourceRow - 1
            var destinationIndex = destinationIndexPath.row - 1

            // Adjust destination index if it is after the source index due to removal of the source item
            if sourceIndex < destinationIndex {
                destinationIndex -= 1
            }

            let movedObject = self.dropLocations.remove(at: sourceIndex)
            self.dropLocations.insert(movedObject, at: destinationIndex)

            let movedObjectStr = self.dropLocationsStr[sourceIndex]
            self.dropLocationsStr.removeObject(at: sourceIndex)
            self.dropLocationsStr.insert(movedObjectStr, at: destinationIndex)

            let movedAnnotation = self.pointsAnnotations.remove(at: sourceIndex + 1)
            self.pointsAnnotations.insert(movedAnnotation, at: destinationIndex + 1)
            self.tableView.reloadData()
//            tableView.performBatchUpdates({
//                tableView.moveRow(at: IndexPath(row: sourceRow, section: 0), to: IndexPath(row: destinationIndex + 1, section: 0))
//            }, completion: nil)
        }
    }
}


//import UIKit
//import MapKit
//import GooglePlaces
//
//class BottomSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GMSAutocompleteViewControllerDelegate {
//
//    var pickupLocation: CLLocationCoordinate2D?
//    var dropLocations: [CLLocationCoordinate2D] = []
//    var mapView: MKMapView?
//    var pickupLocationstr: String?
//    var dropLocationsStr = NSMutableArray()
//    var pointsAnnotations: [MKPointAnnotation] = []
//    var editingIndexPath: IndexPath?
//
//    @IBOutlet weak var tableView: UITableView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UINib(nibName: "PickupLocationCell", bundle: nil), forCellReuseIdentifier: "PickupLocationCell")
//        tableView.register(UINib(nibName: "DropLocationCell", bundle: nil), forCellReuseIdentifier: "DropLocationCell")
//        tableView.layer.cornerRadius = 20
//
//        // Enable reordering
//        tableView.setEditing(true, animated: false)
//
//        if dropLocations.isEmpty {
//            dropLocations.append(CLLocationCoordinate2D(latitude: 0, longitude: 0))
//        }
//        print(dropLocationsStr)
//    }
//
//    @IBAction func CalllDone(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//        NotificationCenter.default.post(name: Notification.Name("CallDone"), object: pointsAnnotations)
//    }
//
//    @IBAction func addButtonTapped(_ sender: UIButton) {
//        addDropLocation()
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // Include 1 for pickup location and 1 for the add button if less than 7 drop locations
//        return 1 + dropLocations.count + (dropLocations.count < 7 ? 1 : 0)
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            // Pickup Location Cell
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PickupLocationCell", for: indexPath) as! PickupLocationCell
//            cell.pickupLocationTextField.text = pickupLocation == nil ? "Set Pickup Location" : pickupLocationstr
//
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openAutocompleteForPickupLocation))
//            cell.pickupLocationTextField.isUserInteractionEnabled = true
//            cell.pickupLocationTextField.addGestureRecognizer(tapGesture)
//
//            return cell
//        } else if indexPath.row == dropLocations.count + 1 {
//            // Add Button Cell
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PickupLocationCell", for: indexPath) as! PickupLocationCell
//            cell.pickupLocationTextField.text = ""
//            cell.pickupLocationTextField.placeholder = "Add Stop"
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addDropLocation))
//            cell.pickupLocationTextField.isUserInteractionEnabled = true
//            cell.pickupLocationTextField.addGestureRecognizer(tapGesture)
//            return cell
//        } else {
//            // Drop Location Cell
//            let cell = tableView.dequeueReusableCell(withIdentifier: "DropLocationCell", for: indexPath) as! DropLocationCell
//            let dropLocationIndex = indexPath.row - 1
//            cell.dropLocationTextField.placeholder = "Drop Location \(dropLocationIndex + 1)"
//            cell.deleteButton.isHidden = dropLocations.count <= 1
//            cell.dropLocationTextField.text = dropLocationsStr[dropLocationIndex] as? String
//
//            cell.onDeleteButtonTapped = { [weak self] in
//                self?.removeDropLocation(at: dropLocationIndex)
//            }
//
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openAutocompleteForDropLocation(_:)))
//            cell.dropLocationTextField.isUserInteractionEnabled = true
//            cell.dropLocationTextField.addGestureRecognizer(tapGesture)
//            cell.dropLocationTextField.tag = indexPath.row
//
//            return cell
//        }
//    }
//
//    @objc func openAutocompleteForPickupLocation() {
//        editingIndexPath = IndexPath(row: 0, section: 0)
//        openAutocompleteController()
//    }
//
//    @objc func openAutocompleteForDropLocation(_ sender: UITapGestureRecognizer) {
//        if let tag = sender.view?.tag {
//            editingIndexPath = IndexPath(row: tag, section: 0)
//            openAutocompleteController()
//        }
//    }
//
//    func openAutocompleteController() {
//        let autocompleteController = GMSAutocompleteViewController()
//        autocompleteController.delegate = self
//        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
//                                                  UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.coordinate.rawValue)  | UInt(GMSPlaceField.formattedAddress.rawValue) |  UInt(GMSPlaceField.defaultFields.rawValue))!
//        autocompleteController.placeFields = fields
//        present(autocompleteController, animated: true, completion: nil)
//    }
//
//    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//        if let indexPath = editingIndexPath {
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = place.coordinate
//            annotation.title = place.formattedAddress
//
//            if indexPath.row == 0 {
//                // Update pickup location
//                pickupLocation = place.coordinate
//                pickupLocationstr = place.formattedAddress
//                pointsAnnotations.remove(at: 0)
//                pointsAnnotations.insert(annotation, at: 0)
//            }
//            else if indexPath.row == dropLocations.count + 1 {
//                dropLocationsStr.add(place.formattedAddress ?? "")
//
//                let ann = MKPointAnnotation()
//                ann.coordinate = place.coordinate
//                ann.title = place.formattedAddress
//
//                pointsAnnotations.append(ann)
//                let newDropLocation = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
//                dropLocations.append(newDropLocation)
//                NotificationCenter.default.post(name: Notification.Name("Increaseheight"), object: nil)
//            }
//            else {
//                // Update drop location
//                let dropLocationIndex = indexPath.row
//                dropLocations.remove(at: dropLocationIndex - 1)
//                dropLocations.insert(place.coordinate, at: dropLocationIndex - 1)
//                dropLocationsStr.removeObject(at: dropLocationIndex - 1)
//                dropLocationsStr.insert(place.formattedAddress ?? "", at: dropLocationIndex - 1)
//                pointsAnnotations.remove(at: dropLocationIndex)
//                pointsAnnotations.insert(annotation, at: dropLocationIndex)
//            }
//            tableView.reloadData()
//        }
//        dismiss(animated: true, completion: nil)
//    }
//
//    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
//        print("Error: \(error)")
//        dismiss(animated: true, completion: nil)
//    }
//
//    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @objc func addDropLocation() {
//        editingIndexPath = IndexPath(row: dropLocations.count + 1, section: 0)
//        openAutocompleteController()
//    }
//
//    func removeDropLocation(at index: Int) {
//        dropLocations.remove(at: index)
//        pointsAnnotations.remove(at: index + 1)
//        dropLocationsStr.removeObject(at: index)
//        if dropLocations.isEmpty {
//            dropLocations.append(CLLocationCoordinate2D(latitude: 0, longitude: 0))
//        }
//        NotificationCenter.default.post(name: Notification.Name("Decreaseheight"), object: nil)
//        tableView.reloadData()
//    }
//
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Allow reordering for pickup and drop locations, but not for "Add Stop" cell
//        return indexPath.row != dropLocations.count + 1
//    }
//
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        if sourceIndexPath.row == 0 {
//            // Handle reordering of pickup location
//            if destinationIndexPath.row > 0 && destinationIndexPath.row <= dropLocations.count {
//                // Moving pickup location to within the range of drop locations
//                let movedLocation = pickupLocation
//                pickupLocation = nil
//                dropLocations.insert(movedLocation!, at: destinationIndexPath.row - 1)
//                dropLocationsStr.insert(pickupLocationstr ?? "", at: destinationIndexPath.row - 1)
//            } else if destinationIndexPath.row == dropLocations.count + 1 {
//                // Moving pickup location to just before "Add Stop" cell
//                let movedLocation = pickupLocation
//                pickupLocation = nil
//                dropLocations.append(movedLocation!)
//                dropLocationsStr.add(pickupLocationstr ?? "")
//            }
//        } else if sourceIndexPath.row == dropLocations.count + 1 {
//            // Handle reordering of "Add Stop" cell
//            // This cell should always stay at the last index
//            return
//        } else {
//            // Handle reordering of drop location cells
//            let movedLocation = dropLocations.remove(at: sourceIndexPath.row - 1)
//            dropLocations.insert(movedLocation, at: destinationIndexPath.row - 1)
//
//            let movedLocationStr = dropLocationsStr.removeObject(at: sourceIndexPath.row - 1)
//            dropLocationsStr.insert(movedLocationStr, at: destinationIndexPath.row - 1)
//
//            let movedAnnotation = pointsAnnotations.remove(at: sourceIndexPath.row)
//            pointsAnnotations.insert(movedAnnotation, at: destinationIndexPath.row)
//        }
//    }
//
//}
