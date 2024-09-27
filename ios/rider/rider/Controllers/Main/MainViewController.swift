//
//  MainViewController.swift
//  Rider
//
//  Copyright © 2019 minimalistic apps. All rights reserved.
//

import UIKit
import MapKit
import Contacts
import GooglePlaces
import PlacesPicker
import GooglePlacesPicker
import BottomSheet
import GoogleMaps
class MainViewController: UIViewController, CLLocationManagerDelegate, ServiceRequested, PlacesPickerDelegate, GMSAutocompleteViewControllerDelegate {
    @IBOutlet weak var dropsaved: UIButton!
    @IBOutlet weak var PikupView: CustomUIView!
    @IBOutlet weak var dropview: CustomUIView!
    @IBOutlet weak var psaved: UIButton!
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place)")
        print("Place address: \(place.formattedAddress ?? "")")
//        print("Place attributions: \(place.addressComponents)")
        
        let ann = MKPointAnnotation()
        ann.coordinate = place.coordinate
        ann.title = place.formattedAddress
        
        if(FromLoc == "pickUp"){
            
            if (self.pointsAnnotations.count == 0){
                self.pointsAnnotations.append(ann)
            }else{
                self.pointsAnnotations.remove(at: 0)
                self.pointsAnnotations.insert(ann, at: 0)
            }
            PickuPtextfeild.text = "\(place.formattedAddress ?? "")"
            
        }
      else  if(FromLoc == "Drop"){
            DropTextfeild.text = "\(place.formattedAddress ?? "")"
          
          if (self.pointsAnnotations.count == 1){
              self.pointsAnnotations.append(ann)
          }else if (self.pointsAnnotations.count > 1){
              self.pointsAnnotations.removeLast()
              self.pointsAnnotations.append(ann)
          }
          self.buttonConfirmFinalDestination.isHidden = false
          self.leftBarButton.image = UIImage(named: "back")
          self.buttonAddDestination.isEnabled = true
          self.AddmoreDesButton.isEnabled = true
          self.AddmoreDesButton.isEnabled = true
        }
//        if pointsAnnotations.count >= 2 {
//            map.removeAnnotations(pointsAnnotations)
//            let waypoints = pointsAnnotations.map { $0.coordinate }
//            drawRoute(waypoints: waypoints)
//            map.layoutMargins = UIEdgeInsets(top: 100, left: 0, bottom: 305, right: 0)
//            map.showAnnotations(pointsAnnotations, animated: true)
//
//        }
        self.map.setCenter(place.coordinate, animated: true)

        dismiss(animated: true, completion: nil)
      }

      func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: \(error)")
        dismiss(animated: true, completion: nil)
      }

      // User cancelled the operation.
      func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        dismiss(animated: true, completion: nil)
      }
    
    func placePickerControllerDidCancel(controller: PlacePickerController) {
           controller.navigationController?.dismiss(animated: true, completion: nil)
       }
       
       func placePickerController(controller: PlacePickerController, didSelectPlace place: GMSPlace) {
           controller.navigationController?.dismiss(animated: true, completion: nil)
       }
    
    @IBOutlet weak var map: MKMapView!
    var pointsAnnotations: [MKPointAnnotation] = []
    var arrayDriversMarkers: [MKPointAnnotation] = []
    var locationManager = CLLocationManager()
    var servicesViewController: ServicesParentViewController?
    var pinAnnotation:MKPinAnnotationView = MKPinAnnotationView()
    var FromLoc = "pickUp"
    var AddMore = false

    private var searchController: UISearchController!
    @IBOutlet weak var buttonConfirmPickup: ColoredButton!
    @IBOutlet weak var buttonAddDestination: ColoredButton!
    @IBOutlet weak var buttonConfirmFinalDestination: ColoredButton!
    @IBOutlet weak var containerServices: UIView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var buttonFavorites: UIBarButtonItem!
    
    @IBOutlet weak var DropTextfeild: UITextField!
    @IBOutlet weak var PickuPtextfeild: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        AddmoreDesButton.isEnabled = false
        AddmoreDesButton.setTitle("", for: .normal)
        psaved.setTitle("", for: .normal)

        dropsaved.setTitle("", for: .normal)
        PikupView.isUserInteractionEnabled = true
        dropview.isUserInteractionEnabled = true

        PlacePicker.configure(googleMapsAPIKey: "AIzaSyCW_G5rejKDXuhXYN8sITHhPRdX9_zbK5A", placesAPIKey: "AIzaSyCW_G5rejKDXuhXYN8sITHhPRdX9_zbK5A")
//        DropTextfeild.isEnabled = false
        buttonAddDestination.isHidden = true
        buttonConfirmFinalDestination.isHidden = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        map.delegate = self
        buttonConfirmPickup.isHidden = true
        pinAnnotation.frame = CGRect(x: (self.view.frame.width / 2) - 8, y: self.view.frame.height / 2 - 8, width: 32, height: 39)
        pinAnnotation.pinTintColor = UIColor.darkGray //UIApplication.shared.keyWindow?.tintColor
        map.addSubview(pinAnnotation)
//        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "SuggestionsTableTableViewController") as! SuggestionsTableTableViewController
//        locationSearchTable.callback = self
//        searchController = UISearchController(searchResultsController: locationSearchTable)
//        searchController?.searchResultsUpdater = locationSearchTable
//        searchController?.hidesNavigationBarDuringPresentation = false
//        definesPresentationContext = true
//        //self.performSegue(withIdentifier: "showBottomSheet", sender: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleCallDoneNotification(_:)), name: Notification.Name("CallDone"), object: nil)
        NotificationCenter.default.addObserver(forName: Notification.Name("CallEdit"), object: nil, queue: .main) { notification in
            self.goEditFromServiceSelection()
        }
        
        PickuPtextfeild.delegate = self
              DropTextfeild.delegate = self
       // self.navigationItem.searchController = searchController
      //  self.navigationItem.searchController?.searchBar.backgroundColor = .white
        GetCurrentRequestInfo().execute() { result in
            switch result {
            case .success(let response):
                Request.shared = response.request
                if response.request.status == .Booked || response.request.status == .Requested || response.request.status == .Found {
                    self.performSegue(withIdentifier: "startLooking", sender: nil)
                } else {
                    self.performSegue(withIdentifier: "startTravel", sender: nil)
                }
                
            case .failure(_):
                break
            }
        }
    }
    @objc func handleCallDoneNotification(_ notification: Notification) {
//        pointsAnnotations.removeAll()
//        drawRoute(waypoints: [])
//
        let overlays = map.overlays
//        map.removeOverlays(overlays)
//        map.reloadInputViews()
//
        map.removeOverlays(overlays)
//
        map.removeAnnotations(map.annotations)

        
           if let annotations = notification.object as? [MKPointAnnotation] {
               // Handle the received annotations
              
             pointsAnnotations = annotations
               
               PickuPtextfeild.text = pointsAnnotations.first?.title
               DropTextfeild.text = pointsAnnotations.last?.title
               FromLoc = ""
               if pointsAnnotations.count >= 2 {
                   let waypoints = pointsAnnotations.map { $0.coordinate }
                   drawRoute(waypoints: waypoints)
//                   self.map.setCenter(pointsAnnotations.last!.coordinate, animated: true)
//                   let region = MKCoordinateRegion(center: pointsAnnotations.last!.coordinate, latitudinalMeters: 200, longitudinalMeters: 200) // Adjust these values for a higher zoom level
//                   map.setRegion(region, animated: true)

                   self.pinAnnotation.isHidden = true
                   map.isUserInteractionEnabled = true
                   map.layoutMargins = UIEdgeInsets(top: 100, left: 0, bottom: 305, right: 0)
                   map.showAnnotations(pointsAnnotations, animated: true)
                   PikupView.isUserInteractionEnabled = true
                   dropview.isUserInteractionEnabled = true

               }

           }
       }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = .black
            polylineRenderer.lineWidth = 2.0
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
   
    func goBackFromServiceSelection() {
        LoadingOverlay.shared.hideOverlayView()
        leftBarButton.image = UIImage(named: "menu")
        map.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        map.removeAnnotations(map.annotations)
        map.removeOverlays(map.overlays)
        AddmoreDesButton.isEnabled = false
        AddMore = false
        pointsAnnotations.removeAll()
        buttonAddDestination.isHidden = true
        buttonConfirmFinalDestination.isHidden = true
//        buttonConfirmPickup.isHidden = false
        buttonFavorites.isEnabled = true
        self.containerServices.isHidden = true
        self.pinAnnotation.isHidden = false
        map.isUserInteractionEnabled = true
        FromLoc = "pickUp"
        self.DropTextfeild.text = ""
        self.locationManager.startUpdatingLocation()
        PikupView.isUserInteractionEnabled = true
        dropview.isUserInteractionEnabled = true

    }
    func goEditFromServiceSelection() {
        LoadingOverlay.shared.hideOverlayView()
        AddmoreDesButton.isEnabled = true
        AddMore = true
        buttonConfirmFinalDestination.isHidden = false
        self.containerServices.isHidden = true
        map.isUserInteractionEnabled = true
        self.locationManager.startUpdatingLocation()
        PikupView.isUserInteractionEnabled = true
        dropview.isUserInteractionEnabled = true

    }
    @IBAction func edit(_ sender: Any) {
    }
    @IBOutlet weak var AddmoreDesButton: UIButton!
//    @IBAction func AddMoreDestinationButton(_ sender: Any) {
////        presentBottomSheet(
////            viewController: BottomSheetViewController,
////            configuration: BottomSheetConfiguration(
////                cornerRadius: 10,
////                pullBarConfiguration: .visible(.init(height: 20)),
////                shadowConfiguration: .init(backgroundColor: UIColor.black.withAlphaComponent(0.6))
////            ),
////            canBeDismissed: {
////                // return `true` or `false` based on your business logic
////                true
////            },
////            dismissCompletion: {
////                // handle bottom sheet dismissal completion
////            }
////        )
//        AddMore = true
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let BottomSheetViewController = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as! BottomSheetViewController
//        if pointsAnnotations.count < 2
//        {
//            let ann = MKPointAnnotation()
//            ann.coordinate = map.camera.centerCoordinate
//           // ann.title = (self.navigationItem.searchController?.searchBar.text)!
//            ann.title = DropTextfeild.text
//
//            pointsAnnotations.append(ann)
//            map.addAnnotation(ann)
//            let cameraTarget = CLLocationCoordinate2D(latitude: map.camera.centerCoordinate.latitude + 0.0015, longitude: map.camera.centerCoordinate.longitude)
//            map.setCenter(cameraTarget, animated: true)
//            BottomSheetViewController.preferredContentSize.height = 260
//            BottomSheetViewController.pickupLocationstr = PickuPtextfeild.text
//            BottomSheetViewController.pickupLocation = pointsAnnotations[0].coordinate
//            BottomSheetViewController.dropLocations.removeAll()
//            BottomSheetViewController.dropLocationsStr.removeAllObjects()
//
//            BottomSheetViewController.dropLocations.append(pointsAnnotations[1].coordinate)
//            BottomSheetViewController.dropLocationsStr.add(DropTextfeild.text ?? "")
//
//        }else if pointsAnnotations.count > 2{
//            BottomSheetViewController.pickupLocationstr = PickuPtextfeild.text
//            BottomSheetViewController.pickupLocation = pointsAnnotations[0].coordinate
//        }
//
//
//
//        BottomSheetViewController.pointsAnnotations = pointsAnnotations
//        NotificationCenter.default.addObserver(forName: Notification.Name("Increaseheight"), object: nil, queue: .main) { notification in
//            BottomSheetViewController.preferredContentSize.height = BottomSheetViewController.preferredContentSize.height + 50
//
//        }
//
//        NotificationCenter.default.addObserver(forName: Notification.Name("Decreaseheight"), object: nil, queue: .main) { notification in
//            BottomSheetViewController.preferredContentSize.height = BottomSheetViewController.preferredContentSize.height - 50
//
//        }
//
////        let viewController = BottomSheetViewController()
//           presentBottomSheetInsideNavigationController(
//               viewController: BottomSheetViewController,
//               configuration: BottomSheetConfiguration(
//                   cornerRadius: 15,
//                   pullBarConfiguration: .hidden,
//                   shadowConfiguration: .init(backgroundColor: UIColor.black.withAlphaComponent(0.6))
//               ),
//               canBeDismissed: {
//                   // return `true` or `false` based on your business logic
//                   false
//               },
//               dismissCompletion: {
//                   // handle bottom sheet dismissal completion
//               }
//           )
//    }
    @IBAction func AddMoreDestinationButton(_ sender: Any) {
        AddMore = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let BottomSheetViewController = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as! BottomSheetViewController
        
        // Clear previous drop locations
        BottomSheetViewController.dropLocations.removeAll()
        BottomSheetViewController.dropLocationsStr.removeAllObjects()
        
        if pointsAnnotations.count < 2 {
            let ann = MKPointAnnotation()
            ann.coordinate = map.camera.centerCoordinate
            ann.title = DropTextfeild.text
            pointsAnnotations.append(ann)
            map.addAnnotation(ann)
            let cameraTarget = CLLocationCoordinate2D(latitude: map.camera.centerCoordinate.latitude + 0.0015, longitude: map.camera.centerCoordinate.longitude)
            map.setCenter(cameraTarget, animated: true)
            BottomSheetViewController.preferredContentSize.height = 260
            
            // Set pickup location
            BottomSheetViewController.pickupLocationstr = PickuPtextfeild.text
            BottomSheetViewController.pickupLocation = pointsAnnotations[0].coordinate
            
            // Add the first drop location
            BottomSheetViewController.dropLocations.append(pointsAnnotations[1].coordinate)
            BottomSheetViewController.dropLocationsStr.add(DropTextfeild.text ?? "")
        } else {
            // Set pickup location
            BottomSheetViewController.pickupLocationstr = PickuPtextfeild.text
            BottomSheetViewController.pickupLocation = pointsAnnotations[0].coordinate
            BottomSheetViewController.preferredContentSize.height = CGFloat(160 + ( pointsAnnotations.count * 50))

            // Add all drop locations starting from the 1st index
            for i in 1..<pointsAnnotations.count {
                BottomSheetViewController.dropLocations.append(pointsAnnotations[i].coordinate)
                if let title = pointsAnnotations[i].title {
                    BottomSheetViewController.dropLocationsStr.add(title)
                } else {
                    BottomSheetViewController.dropLocationsStr.add("Drop Location \(i)")
                }
            }
        }
        
        BottomSheetViewController.pointsAnnotations = pointsAnnotations
        
        NotificationCenter.default.addObserver(forName: Notification.Name("Increaseheight"), object: nil, queue: .main) { notification in
            BottomSheetViewController.preferredContentSize.height += 50
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("Decreaseheight"), object: nil, queue: .main) { notification in
            BottomSheetViewController.preferredContentSize.height -= 50
        }
        
        presentBottomSheetInsideNavigationController(
            viewController: BottomSheetViewController,
            configuration: BottomSheetConfiguration(
                cornerRadius: 15,
                pullBarConfiguration: .hidden,
                shadowConfiguration: .init(backgroundColor: UIColor.black.withAlphaComponent(0.6))
            ),
            canBeDismissed: {
                // return `true` or `false` based on your business logic
                false
            },
            dismissCompletion: {
                // handle bottom sheet dismissal completion
            }
        )
    }

    private func handleShowBottomSheet() {
      }
//    func drawRoute(from sourceCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D) {
//        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
//        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
//
//        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
//        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
//
//        let directionsRequest = MKDirections.Request()
//        directionsRequest.source = sourceMapItem
//        directionsRequest.destination = destinationMapItem
//        directionsRequest.transportType = .automobile
//
//        let directions = MKDirections(request: directionsRequest)
//        directions.calculate { response, error in
//            guard let response = response else {
//                if let error = error {
//                    print("Error: \(error.localizedDescription)")
//                }
//                return
//            }
//
//            if let route = response.routes.first {
//                self.map.addOverlay(route.polyline)
//                self.map.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
//            }
//        }
//    }
//    func drawRoute(waypoints: [CLLocationCoordinate2D]) {
//        guard waypoints.count >= 2 else {
//            print("Not enough waypoints to draw route")
//            return
//        }
//
//        // Iterate over the waypoints to create directions requests
//        for i in 0..<(waypoints.count - 1) {
//            let sourceCoordinate = waypoints[i]
//            let destinationCoordinate = waypoints[i + 1]
//
//            let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
//            let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
//
//            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
//            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
//
//            let directionsRequest = MKDirections.Request()
//            directionsRequest.source = sourceMapItem
//            directionsRequest.destination = destinationMapItem
//            directionsRequest.transportType = .automobile
//
//            let directions = MKDirections(request: directionsRequest)
//            directions.calculate { response, error in
//                guard let response = response else {
//                    if let error = error {
//                        print("Error: \(error.localizedDescription)")
//                    }
//                    return
//                }
//
//                if let route = response.routes.first {
//                    self.map.addOverlay(route.polyline)
//                    self.map.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
//                }
//            }
//        }
//    }

    func drawRoute(waypoints: [CLLocationCoordinate2D]) {
        guard waypoints.count >= 2 else {
            print("Not enough waypoints to draw route")
            return
        }

        // Remove existing overlays
        

        // Iterate over the waypoints to create directions requests
        for i in 0..<(waypoints.count - 1) {
            let sourceCoordinate = waypoints[i]
            let destinationCoordinate = waypoints[i + 1]

            let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
            let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)

            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

            let directionsRequest = MKDirections.Request()
            directionsRequest.source = sourceMapItem
            directionsRequest.destination = destinationMapItem
            directionsRequest.transportType = .automobile

            let directions = MKDirections(request: directionsRequest)
            directions.calculate { response, error in
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                    return
                }

                if let route = response.routes.first {
                    self.map.addOverlay(route.polyline)
                    self.map.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ServicesParentViewController,
            segue.identifier == "segueServices" {
            self.servicesViewController = vc
            vc.callback = self
        }
        if let vc = segue.destination as? LookingViewController, segue.identifier == "startLooking" {
            vc.delegate = self
        }
        if let vc = segue.destination as? BottomSheetViewController, segue.identifier == "showBottomSheet" {
                   vc.mapView = map
                   // Pass current pickup and drop locations
               }
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        guard let position = manager.location else {
            let alert = UIAlertController(title: NSLocalizedString("Message", comment: ""), message: NSLocalizedString("Couldn't get current location. use search to find your current place on map.", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Allright!", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let region = MKCoordinateRegion(center: position.coordinate, latitudinalMeters: 200, longitudinalMeters: 200) // Adjust these values for a higher zoom level
        map.setRegion(region, animated: true)
    }
    
    @IBAction func onMenuClicked(_ sender: UIBarButtonItem) {
        if(pointsAnnotations.count == 0 ||  leftBarButton.image  ==  UIImage(named: "menu") ) {
            NotificationCenter.default.post(name: .menuClicked, object: nil)
            return
        }
//        if(!pinAnnotation.isHidden) {
//            map.removeAnnotation(pointsAnnotations.last!)
//            pointsAnnotations.removeLast()
//           // buttonConfirmPickup.isHidden = (pointsAnnotations.count != 0)
//            buttonConfirmFinalDestination.isHidden = (pointsAnnotations.count == 0 || AppDelegate.singlePointMode)
//            buttonAddDestination.isHidden = (pointsAnnotations.count > (AppDelegate.maximumDestinations - 1) || AppDelegate.singlePointMode || pointsAnnotations.count == 0)
//            leftBarButton.image = (pointsAnnotations.count == 0 ? UIImage(named: "menu") : UIImage(named: "back"))
//            return
//        }
        
        else{
            let alert = UIAlertController(title: "Confirm", message: "If you go back, all your stops will be cleared. To edit your route, click the Edit icon", preferredStyle: .alert)
                
                let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                    // Handle the "Yes" response here
                    print("User selected Yes")
                    // Add your code for handling the "Yes" action
                    self.goBackFromServiceSelection()

                }
                
                let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
                    // Handle the "No" response here
                    print("User selected No")
                    // Add your code for handling the "No" action
                }
                
                alert.addAction(yesAction)
                alert.addAction(noAction)
                
                // Present the alert
                if let topController = UIApplication.shared.keyWindow?.rootViewController {
                    topController.present(alert, animated: true, completion: nil)
                }
        }
    }
    
    @IBAction func picupAddressfromSaved(_ sender: Any) {
        FromLoc = "pickUp"

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
                    
                    self.PickuPtextfeild.text = response[pickerView.selectedRow(inComponent: 0)].address!
                    
                    
                    let ann = MKPointAnnotation()
                    ann.coordinate = response[pickerView.selectedRow(inComponent: 0)].location!
                    ann.title = response[pickerView.selectedRow(inComponent: 0)].address!
                    if (self.pointsAnnotations.count == 0){
                        self.pointsAnnotations.append(ann)
                    }else{
                        self.pointsAnnotations.remove(at: 0)
                        self.pointsAnnotations.insert(ann, at: 0)
                    }
                   
                   
//                    map.addAnnotation(ann)
//                    let cameraTarget = CLLocationCoordinate2D(latitude: map.camera.centerCoordinate.latitude + 0.0015, longitude: map.camera.centerCoordinate.longitude)
//                    map.setCenter(cameraTarget, animated: true)
//
                    self.pinAnnotation.isHidden = false

                    self.map.setCenter(response[pickerView.selectedRow(inComponent: 0)].location!, animated: true)
                })
                dlg.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(dlg, animated: true)
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    @IBAction func dropAddressfromSaved(_ sender: Any) {
        FromLoc = "Drop"
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
                    self.DropTextfeild.text = response[pickerView.selectedRow(inComponent: 0)].address!
                    let ann = MKPointAnnotation()
                    ann.coordinate = response[pickerView.selectedRow(inComponent: 0)].location!
                    ann.title = response[pickerView.selectedRow(inComponent: 0)].address!
                    if (self.pointsAnnotations.count == 1){
                        self.pointsAnnotations.append(ann)
                    }else if (self.pointsAnnotations.count > 1){
                        self.pointsAnnotations.removeLast()
                        self.pointsAnnotations.append(ann)
                    }
                    self.pinAnnotation.isHidden = false

                    self.map.setCenter(response[pickerView.selectedRow(inComponent: 0)].location!, animated: true)
                    self.buttonConfirmFinalDestination.isHidden = false
                    self.leftBarButton.image = UIImage(named: "back")
                    self.AddmoreDesButton.isEnabled = true
                })
                dlg.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(dlg, animated: true)
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    @IBAction func onFavoritesClicked(_ sender: UIBarButtonItem) {
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
                    self.map.setCenter(response[pickerView.selectedRow(inComponent: 0)].location!, animated: true)
                })
                dlg.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(dlg, animated: true)
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
    func RideNowSelected(service: Service) {
        LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
        let locs = pointsAnnotations.map() { annotation in
            return LocationWithName(loc: annotation.coordinate, add: annotation.title!)
        }
        
        print("Loca1",locs.first?.add ?? "")
        UserDefaults.standard.set(locs.first?.add, forKey: "LOCA")
        print("Loca2",locs.last?.add ?? "")
        UserDefaults.standard.set(locs.last?.add, forKey: "LOCB")

        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        RequestService(obj: RequestDTO(locations: locs, services: [OrderedService(serviceId: service.id!, quantity: 1)])).execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(_):
                Request.shared.status = Request.Status.Requested
                self.performSegue(withIdentifier: "startLooking", sender: nil)
                self.goBackFromServiceSelection()
                
            case .failure(let error):
                if error.status == .CreditInsufficient {
                    self.openWallet(amount: service.cost!, currency: self.servicesViewController!.calculateFareResult.currency)
                    return
                }
                error.showAlert()
            }
        }
    }
    
    func RideLaterSelected(service: Service, minutesFromNow: Int) {
        let locs = pointsAnnotations.map() { annotation in
            return LocationWithName(loc: annotation.coordinate, add: annotation.title!)
        }
        LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
        RequestService(obj: RequestDTO(locations: locs, services: [OrderedService(serviceId: service.id!, quantity: 1)], intervalMinutes: minutesFromNow)).execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(_):
                Request.shared.status = minutesFromNow < 30 ? Request.Status.Requested : Request.Status.Booked
                self.performSegue(withIdentifier: "startLooking", sender: nil)
                self.goBackFromServiceSelection()
                
            case .failure(let error):
                if error.status == .CreditInsufficient {
                    self.openWallet(amount: service.cost!, currency: self.servicesViewController!.calculateFareResult.currency)
                    return
                }
                error.showAlert()
            }
        }
    }
    
    func openWallet(amount: Double, currency: String) {
        let alert = UIAlertController(title: NSLocalizedString("Message", comment: ""), message: NSLocalizedString("Credit in wallet is not sufficient to do this. Please top up your wallet first.", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Open Wallet", comment: ""), style: .default) {_ in
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Wallet") as? WalletViewController {
                vc.amount = amount
                vc.currency = currency
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true)
        return
    }
    
    @IBAction func onButtonConfirmPickupTouched(_ sender: ColoredButton) {
        leftBarButton.image = UIImage(named: "back")
        DropTextfeild.isEnabled = true
        
        AddmoreDesButton.isEnabled = true

        AddDestination()
        if(AppDelegate.singlePointMode) {
            calculateFare()
        }
        
    }
    
    @IBAction func onButtonAddDestinationTouched(_ sender: Any) {
        AddDestination()
    }
    
    @IBAction func onButtonFinalDestinationTouched(_ sender: Any) {
      //  AddDestination()
        FromLoc = ""
        let overlays = map.overlays
        map.removeOverlays(overlays)
        map.removeAnnotations(map.annotations)

        if pointsAnnotations.count >= 2 {
            let waypoints = pointsAnnotations.map { $0.coordinate }
            drawRoute(waypoints: waypoints)
        }
        calculateFare()
        AddmoreDesButton.isEnabled = false
        PikupView.isUserInteractionEnabled = false
        dropview.isUserInteractionEnabled = false
    }
    
    func AddDestination() {
        
        if AddMore == false {
            let ann = MKPointAnnotation()
            ann.coordinate = map.camera.centerCoordinate
           // ann.title = (self.navigationItem.searchController?.searchBar.text)!
            if(FromLoc == "pickUp"){
                ann.title = PickuPtextfeild.text
                
            }
          else  if(FromLoc == "Drop"){
              ann.title = DropTextfeild.text
            }
           
            pointsAnnotations.append(ann)
            map.addAnnotation(ann)
            let cameraTarget = CLLocationCoordinate2D(latitude: map.camera.centerCoordinate.latitude + 0.0015, longitude: map.camera.centerCoordinate.longitude)
            map.setCenter(cameraTarget, animated: true)
        }
        FromLoc = "Drop"
        if pointsAnnotations.count >= 2 {
            let waypoints = pointsAnnotations.map { $0.coordinate }
            drawRoute(waypoints: waypoints)
        }
        if(!AppDelegate.singlePointMode) {
            buttonConfirmPickup.isHidden = true
            buttonConfirmFinalDestination.isHidden = false
//            buttonAddDestination.isHidden = (pointsAnnotations.count > (AppDelegate.maximumDestinations - 1))
        }
    }
    
    func calculateFare() {
        LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
        buttonFavorites.isEnabled = false
        self.pinAnnotation.isHidden = true
        map.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 305, right: 0)
        map.showAnnotations(pointsAnnotations, animated: true)
        map.isUserInteractionEnabled = false
        let locs = pointsAnnotations.map() { return $0.coordinate }
        CalculateFare(locations: locs).execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(let response):
                self.servicesViewController?.calculateFareResult = response
                self.containerServices.isHidden = false
                self.servicesViewController?.reload()
                
            case .failure(let error):
                self.goBackFromServiceSelection()
                error.showAlert()
            }
        }
    }
    
    func getAddressForLatLng(location: CLLocationCoordinate2D) {
//        let geocoder = CLGeocoder()
//        let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
//        geocoder.reverseGeocodeLocation(loc) { (placemarks, error) in
//            if error == nil {
//                let firstLocation = placemarks?[0]
//               // let addressString = CNPostalAddressFormatter().string(from: firstLocation!.postalAddress!)
//              //  self.navigationItem.searchController?.searchBar.text = addressString
//                var addressString : String = ""
//
//                let pm = placemarks! as [CLPlacemark]
//
//                            if pm.count > 0 {
//                                let pm = placemarks![0]
//                                print(pm.country)
//                                print(pm.locality)
//                                print(pm.subLocality)
//                                print(pm.thoroughfare)
//                                print(pm.postalCode)
//                                print(pm.subThoroughfare)
//                                print(pm.administrativeArea)
//                                print(pm.region)
//                                print(pm.subAdministrativeArea)
//                                print(pm.areasOfInterest)
//
//
//                                if pm.subLocality != nil {
//                                    addressString = addressString + pm.subLocality! + ", "
//                                }
//                                if pm.thoroughfare != nil {
//                                    addressString = addressString + pm.thoroughfare! + ", "
//                                }
//                                if pm.locality != nil {
//                                    addressString = addressString + pm.locality! + ", "
//                                }
//                                if pm.country != nil {
//                                    addressString = addressString + pm.country! + ", "
//                                }
//                                if pm.postalCode != nil {
//                                    addressString = addressString + pm.postalCode! + " "
//                                }
//
//
//                                print(addressString)
//                          }
//
//
               
//            }
     //   }
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(location) { response, error in
          //
            var addressString : String = ""
        if error != nil {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    } else {
                        if let places = response?.results() {
                            if let place = places.first {


                                if let lines = place.lines {
                                    print("GEOCODE: Formatted Address: \(lines)")
                                    
                                    addressString = lines.first ?? ""
                                    
                                    
                                }

                                
                                if(self.FromLoc == "pickUp"){
                                    let ann = MKPointAnnotation()
                                    ann.coordinate = location
                                    ann.title = addressString
                                    if (self.pointsAnnotations.count == 0){
                                        self.pointsAnnotations.append(ann)
                                    }
                                    else{
                                        self.pointsAnnotations.remove(at: 0)
                                        self.pointsAnnotations.insert(ann, at: 0)
                                    }
                                    self.PickuPtextfeild.text = addressString

                                }
                              else  if(self.FromLoc == "Drop"){
                                  self.DropTextfeild.text = addressString


                                  let ann = MKPointAnnotation()
                                  ann.coordinate = location
                                  ann.title = addressString
                                  if (self.pointsAnnotations.count == 1){
                                      self.pointsAnnotations.append(ann)
                                  }else if (self.pointsAnnotations.count > 1){
                                      self.pointsAnnotations.removeLast()
                                      self.pointsAnnotations.append(ann)
                                  }
                                  self.buttonConfirmFinalDestination.isHidden = false
                                  self.leftBarButton.image = UIImage(named: "back")
                                  self.buttonAddDestination.isEnabled = true
                                  self.AddmoreDesButton.isEnabled = true
                                }
                              //  self.PickuPtextfeild.text = addressString
                                self.buttonConfirmPickup.isEnabled = true
                                self.buttonConfirmFinalDestination.isEnabled = true
                                
                                
                            } else {
                                print("GEOCODE: nil first in places")
                            }
                        } else {
                            print("GEOCODE: nil in places")
                        }
                    }
        }
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // The user tapped search on the `UISearchBar` or on the keyboard. Since they didn't
        // select a row with a suggested completion, run the search with the query text in the search field.
    }
}

extension MainViewController: MapSearchDelegate {
    func placeMarkSelected(placemark: MKPlacemark) {
        dismiss(animated: true, completion: {
            self.map.setCenter(placemark.coordinate, animated: true)
            if self.PickuPtextfeild.isFirstResponder {
                self.PickuPtextfeild.text = placemark.title
            } else if self.DropTextfeild.isFirstResponder {
                self.DropTextfeild.text = placemark.title
                   }
        })
    }
}

extension MainViewController: MKMapViewDelegate {
    enum MarkerType: String {
        case pickup = "pickup"
        case dropoff = "dropOff"
        case driver = "driver"
        case Stop = "stop"
    }
    

    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        buttonConfirmPickup.isEnabled = false
        buttonAddDestination.isEnabled = false
        buttonConfirmFinalDestination.isEnabled = false
        /*if(pinAnnotation.dragState == .none) {
            pinAnnotation.dragState = .dragging
            pinAnnotation.setDragState(.starting, animated: true)
        }*/
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? MKPointAnnotation else { return nil }
//        print(annotation.title ?? "")
//        let identifier: MarkerType
//        if(pointsAnnotations.contains(annotation)) {
//            identifier = MarkerType.dropoff
//        } else {
//            identifier = MarkerType.driver
//        }
//        var view: MKMarkerAnnotationView
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier.rawValue) as? MKMarkerAnnotationView {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier.rawValue)
//        }
//        view.backgroundColor = .clear
//        switch(identifier) {
//        case .pickup:
//                // view.glyphImage = UIImage(named: "annotation_glyph_home")
//            view.glyphTintColor = .clear
//
//            view.markerTintColor = UIColor.clear
//            view.image = UIImage(named: "marker_pickup 1")
//            //view.markerTintColor = UIColor(hex: 0x009688)
//            break;
//
//        case .dropoff:
//          //  view.glyphImage = UIImage(named: "annotation_glyph_home")
//            view.glyphTintColor = .clear
//
//            view.markerTintColor = UIColor.clear
//            view.image = UIImage(named: "marker_destination 1")
//           // view.markerTintColor = UIColor(hex: 0xFFA000)
//            break;
//
//        default:
//            view.glyphTintColor = .clear
//
//            view.markerTintColor = UIColor.clear
//            view.image = UIImage(named: "marker_taxi 1")
//        }
//        return view
//    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKPointAnnotation else { return nil }
        print("annotation %@    ",annotation.title ?? "")

        var identifier: MarkerType

        if pointsAnnotations.count > 2 {
            if pointsAnnotations.first == annotation {
                identifier = .pickup
            } else if pointsAnnotations.last == annotation {
                identifier = .dropoff
            } else if pointsAnnotations.contains(annotation) {
                identifier = .Stop
            } else {
                identifier = .driver
            }
        } else {
            if pointsAnnotations.first == annotation {
                identifier = .pickup
            } else if pointsAnnotations.last == annotation {
                identifier = .dropoff
            } else {
                identifier = .driver
            }
        }

        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier.rawValue) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier.rawValue)
        }

        view.backgroundColor = .clear
        view.glyphTintColor = .clear
        view.markerTintColor = .clear

        switch identifier {
        case .pickup:
            view.image = UIImage(named: "marker_p")
        case .dropoff:
            view.image = UIImage(named: "marker_d")
        case .Stop:
            view.image = createNumberedMarkerImage(for: annotation)
        case .driver:
            view.image = UIImage(named: "marker_taxi 1")
        }

        return view
    }

    func createNumberedMarkerImage(for annotation: MKPointAnnotation) -> UIImage? {
        guard let index = pointsAnnotations.firstIndex(of: annotation) else { return nil }
        let stopNumber = index // Since the first is pickup and the last is dropoff

        // Create a UILabel with the number
        let label = UILabel()
        label.text = "\(stopNumber)"
        label.textAlignment = .center
        label.backgroundColor = .black
        label.textColor = UIColor(named: "ThemeYellow")

        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        // Convert the UILabel to UIImage
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if containerServices.isHidden == false { return }
        /*if(pinAnnotation.dragState == .dragging) {
            //pinAnnotation.dragState = .none
            pinAnnotation.setDragState(.ending, animated: false)
            print("End status called")
        }*/
        getAddressForLatLng(location: mapView.camera.centerCoordinate)
        GetDriversLocations(location: mapView.camera.centerCoordinate).execute() { result in
            switch result {
            case .success(let response):
                for driverMarker in self.arrayDriversMarkers {
                    self.map.removeAnnotation(driverMarker)
                }
                self.arrayDriversMarkers.removeAll()
                for location in response {
                    let marker = MKPointAnnotation()
                    marker.coordinate = location
                    //marker.title = "Driver"
                    self.arrayDriversMarkers.append(marker)
                    self.map.addAnnotation(marker)
                }
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
}

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Address.lastDownloaded.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Address.lastDownloaded[row].title;
    }
}

extension MainViewController: LookingDelegate {
    func cancel() {
        
    }
    
    func found() {
        self.performSegue(withIdentifier: "startTravel", sender: nil)
    }
}
extension MainViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == PickuPtextfeild {
            FromLoc = "pickUp"
            if (pointsAnnotations.count>0){
                self.pinAnnotation.isHidden = false
                self.map.setCenter(pointsAnnotations.first!.coordinate, animated: true)

            }
           // searchController.searchBar.placeholder = "Search Pickup Location"
        } else if textField == DropTextfeild {
            //searchController.searchBar.placeholder = "Search Drop-off Location"
            if (pointsAnnotations.count>0){
                
                self.pinAnnotation.isHidden = false
                self.map.setCenter(pointsAnnotations.last!.coordinate, animated: true)

            }
            FromLoc = "Drop"
        }
//        let controller = PlacePicker.placePickerController()
//        controller.delegate = self
//        let navigationController = UINavigationController(rootViewController: controller)
//        self.show(navigationController, sender: nil)
//        //present(searchController, animated: true, completion: nil)
//
//
        
        let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self

            // Specify the place data types to return.
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                      UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.coordinate.rawValue)  | UInt(GMSPlaceField.formattedAddress.rawValue) |  UInt(GMSPlaceField.defaultFields.rawValue))!
            autocompleteController.placeFields = fields

            // Specify a filter.
//            let filter = GMSAutocompleteFilter()
//            filter.types = [.address]
//            autocompleteController.autocompleteFilter = filter

            // Display the autocomplete view controller.
            present(autocompleteController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension UIStackView {
    func addBorder(color: UIColor, backgroundColor: UIColor, thickness: CGFloat) {
        let insetView = UIView(frame: bounds)
        insetView.backgroundColor = backgroundColor
        insetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(insetView, at: 0)

        let borderBounds = CGRect(
            x: thickness,
            y: thickness,
            width: frame.size.width - thickness * 2,
            height: frame.size.height - thickness * 2)

        let borderView = UIView(frame: borderBounds)
        borderView.backgroundColor = color
        borderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(borderView, at: 0)
    }
}
