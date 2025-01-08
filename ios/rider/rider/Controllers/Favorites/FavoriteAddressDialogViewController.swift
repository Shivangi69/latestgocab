////
////  FavoriteAddressDialogViewController.swift
////  rider
////
////  Copyright © 1397 Minimalistic Apps. All rights reserved.
////
//
//import UIKit
//import MapKit
//
//class FavoriteAddressDialogViewController: UIViewController {
//    @IBOutlet weak var textTitle: UITextField!
//    @IBOutlet weak var textAddress: UITextField!
//    var address: Address?
//    @IBOutlet weak var map: MKMapView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        if address != nil {
//            textTitle.text = address?.title
//            textAddress.text = address?.address
//            map.setCenter((address?.location)!, animated: true)
//            let regionRadius: CLLocationDistance = 10 // 1 kilometer
//                       let coordinateRegion = MKCoordinateRegion(center: (address?.location)!, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
//                       map.setRegion(coordinateRegion, animated: true)

//        } else {
//            let locationManager = CLLocationManager()
//            if let location = locationManager.location {
//                map.setCenter(location.coordinate, animated: true)
//                let regionRadius: CLLocationDistance = 10 // 1 kilometer
//                let coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
//                                      map.setRegion(coordinateRegion, animated: true)
//                getAddressFromLatLon(pdblLatitude: String(location.coordinate.latitude), withLongitude: String(location.coordinate.longitude))
//            }
//        }
//
//        // Do any additional setup after loading the view.
//
//        func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
//                var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
//                let lat: Double = Double("\(pdblLatitude)")!
//                //21.228124
//                let lon: Double = Double("\(pdblLongitude)")!
//                //72.833770
//                let ceo: CLGeocoder = CLGeocoder()
//                center.latitude = lat
//                center.longitude = lon
//
//                let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
//
//
//                ceo.reverseGeocodeLocation(loc, completionHandler:
//                    {(placemarks, error) in
//                        if (error != nil)
//                        {
//                            print("reverse geodcode fail: \(error!.localizedDescription)")
//                        }
//                        let pm = placemarks! as [CLPlacemark]
//
//                        if pm.count > 0 {
//                            let pm = placemarks![0]
//                            print(pm.country)
//                            print(pm.locality)
//                            print(pm.subLocality)
//                            print(pm.thoroughfare)
//                            print(pm.postalCode)
//                            print(pm.subThoroughfare)
//                            var addressString : String = ""
//                            if pm.subLocality != nil {
//                                addressString = addressString + pm.subLocality! + ", "
//                            }
//                            if pm.thoroughfare != nil {
//                                addressString = addressString + pm.thoroughfare! + ", "
//                            }
//                            if pm.locality != nil {
//                                addressString = addressString + pm.locality! + ", "
//                            }
//                            if pm.country != nil {
//                                addressString = addressString + pm.country! + ", "
//                            }
//                            if pm.postalCode != nil {
//                                addressString = addressString + pm.postalCode! + " "
//                            }
//
//                            self.textAddress.text = addressString
//                            print(addressString)
//                      }
//                })
//
//            }
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//}
//
//  FavoriteAddressDialogViewController.swift
//  rider
//
//  Copyright © 1397 Minimalistic Apps. All rights reserved.
//

import UIKit
import MapKit

//class FavoriteAddressDialogViewController: UIViewController, UITextFieldDelegate {
//    @IBOutlet weak var textTitle: UITextField!
//    @IBOutlet weak var textAddress: UITextField!
//    var address: Address?
//    @IBOutlet weak var map: MKMapView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        textAddress.delegate = self
//
//        if let address = address {
//            textTitle.text = address.title
//            textAddress.text = address.address
//            map.setCenter((address.location)!, animated: true)
//            let regionRadius: CLLocationDistance = 10 // 1 kilometer
//            let coordinateRegion = MKCoordinateRegion(center: (address.location)!, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
//                       map.setRegion(coordinateRegion, animated: true)
//
//        } else {
//            let locationManager = CLLocationManager()
//            if let location = locationManager.location {
//                centerMapOnLocation(location: location.coordinate)
//                getAddressFromLatLon(pdblLatitude: String(location.coordinate.latitude), withLongitude: String(location.coordinate.longitude))
//            }
//        }
//    }
//
//    func centerMapOnLocation(location: CLLocationCoordinate2D) {
//        let regionRadius: CLLocationDistance = 1000 // 1 kilometer
//        let coordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
//        map.setRegion(coordinateRegion, animated: true)
//    }
//
//    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
//        let ceo: CLGeocoder = CLGeocoder()
//        let loc: CLLocation = CLLocation(latitude: Double(pdblLatitude)!, longitude: Double(pdblLongitude)!)
//
//        ceo.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) in
//            if let error = error {
//                print("Reverse geocode failed: \(error.localizedDescription)")
//                return
//            }
//            guard let placemarks = placemarks, placemarks.count > 0 else {
//                return
//            }
//            let pm = placemarks[0]
//            var addressString: String = ""
//            if let subLocality = pm.subLocality {
//                addressString += subLocality + ", "
//            }
//            if let thoroughfare = pm.thoroughfare {
//                addressString += thoroughfare + ", "
//            }
//            if let locality = pm.locality {
//                addressString += locality + ", "
//            }
//            if let country = pm.country {
//                addressString += country + ", "
//            }
//            if let postalCode = pm.postalCode {
//                addressString += postalCode + " "
//            }
//
//            self.textAddress.text = addressString
//            print(addressString)
//        })
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == textAddress {
//            textField.resignFirstResponder()
//            if let address = textField.text {
//                geocodeAddress(address: address)
//            }
//        }
//        return true
//    }
//
//    func geocodeAddress(address: String) {
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString(address) { (placemarks, error) in
//            if let error = error {
//                print("Geocode failed: \(error.localizedDescription)")
//                return
//            }
//            guard let placemarks = placemarks, placemarks.count > 0 else {
//                return
//            }
//            let placemark = placemarks[0]
//            if let location = placemark.location {
//                self.centerMapOnLocation(location: location.coordinate)
//                self.addAnnotationAtCoordinate(coordinate: location.coordinate)
//            }
//        }
//    }
//
//    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate
//        map.removeAnnotations(map.annotations)
//        map.addAnnotation(annotation)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//}
import UIKit
import MapKit

//class FavoriteAddressDialogViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
//    @IBOutlet weak var textTitle: UITextField!
//    @IBOutlet weak var textAddress: UITextField!
//    var address: Address?
//    @IBOutlet weak var map: MKMapView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        textAddress.delegate = self
//        map.delegate = self
//
//        if let address = address {
//            textTitle.text = address.title
//            textAddress.text = address.address
//            map.setCenter((address.location)!, animated: true)
//            let regionRadius: CLLocationDistance = 10 // 1 kilometer
//            let coordinateRegion = MKCoordinateRegion(center: (address.location)!, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
//
//            map.setRegion(coordinateRegion, animated: true)
//        } else {
//            let locationManager = CLLocationManager()
//            if let location = locationManager.location {
//                centerMapOnLocation(location: location.coordinate)
//                getAddressFromLatLon(pdblLatitude: String(location.coordinate.latitude), withLongitude: String(location.coordinate.longitude))
//            }
//        }
//    }
//
//    func centerMapOnLocation(location: CLLocationCoordinate2D) {
//        let regionRadius: CLLocationDistance = 1000 // 1 kilometer
//        let coordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
//        map.setRegion(coordinateRegion, animated: true)
//    }
//
//    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
//        let ceo: CLGeocoder = CLGeocoder()
//        let loc: CLLocation = CLLocation(latitude: Double(pdblLatitude)!, longitude: Double(pdblLongitude)!)
//
//        ceo.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) in
//            if let error = error {
//                print("Reverse geocode failed: \(error.localizedDescription)")
//                return
//            }
//            guard let placemarks = placemarks, placemarks.count > 0 else {
//                return
//            }
//            let pm = placemarks[0]
//            var addressString: String = ""
//            if let subLocality = pm.subLocality {
//                addressString += subLocality + ", "
//            }
//            if let thoroughfare = pm.thoroughfare {
//                addressString += thoroughfare + ", "
//            }
//            if let locality = pm.locality {
//                addressString += locality + ", "
//            }
//            if let country = pm.country {
//                addressString += country + ", "
//            }
//            if let postalCode = pm.postalCode {
//                addressString += postalCode + " "
//            }
//
//            self.textAddress.text = addressString
//            print(addressString)
//        })
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == textAddress {
//            textField.resignFirstResponder()
//            if let address = textField.text {
//                geocodeAddress(address: address)
//            }
//        }
//        return true
//    }
//
//    func geocodeAddress(address: String) {
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString(address) { (placemarks, error) in
//            if let error = error {
//                print("Geocode failed: \(error.localizedDescription)")
//                return
//            }
//            guard let placemarks = placemarks, placemarks.count > 0 else {
//                return
//            }
//            let placemark = placemarks[0]
//            if let location = placemark.location {
//                self.centerMapOnLocation(location: location.coordinate)
//                self.addAnnotationAtCoordinate(coordinate: location.coordinate)
//            }
//        }
//    }
//
//    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate
//        map.removeAnnotations(map.annotations)
//        map.addAnnotation(annotation)
//    }
//
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        let center = mapView.centerCoordinate
//        getAddressFromLatLon(pdblLatitude: String(center.latitude), withLongitude: String(center.longitude))
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//}
import UIKit
import MapKit
import GoogleMaps
import GooglePlaces
import PlacesPicker
import GooglePlacesPicker
class FavoriteAddressDialogViewController: UIViewController,PlacesPickerDelegate, GMSAutocompleteViewControllerDelegate , UITextFieldDelegate, MKMapViewDelegate {
    @IBOutlet weak var textTitle: UITextField!
    @IBOutlet weak var textAddress: UITextField!
    var address: Address?
    @IBOutlet weak var map: MKMapView!
    
    var isUserInteraction: Bool = true
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place)")
        print("Place address: \(place.formattedAddress)")
        
        let ann = MKPointAnnotation()
        ann.coordinate = place.coordinate
        ann.title = place.formattedAddress
        
            textAddress.text = "\(place.formattedAddress ?? "")"
          
        self.map.setCenter(place.coordinate, animated: true)
        let regionRadius: CLLocationDistance = 10 // 1 kilometer
        let coordinateRegion = MKCoordinateRegion(center: (place.coordinate), latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)

        map.setRegion(coordinateRegion, animated: true)

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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textTitle.delegate = self
        textAddress.delegate = self
        map.delegate = self
        
        if let address = address {
            textTitle.text = address.title
            textAddress.text = address.address
            map.setCenter((address.location)!, animated: true)
            let regionRadius: CLLocationDistance = 10 // 1 kilometer
            let coordinateRegion = MKCoordinateRegion(center: (address.location)!, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)

            map.setRegion(coordinateRegion, animated: true)
        } else {
            let locationManager = CLLocationManager()
            if let location = locationManager.location {
                centerMapOnLocation(location: location.coordinate)
                getAddressFromLatLon(pdblLatitude: String(location.coordinate.latitude), withLongitude: String(location.coordinate.longitude))
            }
        }
    }
    
    func setMapRegion(coordinate: CLLocationCoordinate2D) {
        isUserInteraction = false
        let regionRadius: CLLocationDistance = 1000 // 1 kilometer
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        map.setRegion(coordinateRegion, animated: true)
        isUserInteraction = true
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 1000 // 1 kilometer
        let coordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
//        let loc: CLLocation = CLLocation(latitude: Double(pdblLatitude)!, longitude: Double(pdblLongitude)!)
        let locc :CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:  Double(pdblLatitude)!, longitude: Double(pdblLongitude)!)
//        ceo.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) in
//            if let error = error {
//                print("Reverse geocode failed: \(error.localizedDescription)")
//                return
//            }
//            guard let placemarks = placemarks, placemarks.count > 0 else {
//                return
//            }
//            let pm = placemarks[0]
//            var addressString: String = ""
//            if let subLocality = pm.subLocality {
//                addressString += subLocality + ", "
//            }
//            if let thoroughfare = pm.thoroughfare {
//                addressString += thoroughfare + ", "
//            }
//            if let locality = pm.locality {
//                addressString += locality + ", "
//            }
//            if let country = pm.country {
//                addressString += country + ", "
//            }
//            if let postalCode = pm.postalCode {
//                addressString += postalCode + " "
//            }
//
//            self.textAddress.text = addressString
//            print(addressString)
//        })
        
        
        
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(locc) { response, error in
  
       
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
                                                                
                            } else {
                                print("GEOCODE: nil first in places")
                            }
                        } else {
                            print("GEOCODE: nil in places")
                        }
                    }
            self.textAddress.text = addressString
        }
        
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textAddress {
            if let address = textField.text {
                geocodeAddress(address: address)
                
            }
        }
        textField.resignFirstResponder()

        return true
    }
    
    func geocodeAddress(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print("Geocode failed: \(error.localizedDescription)")
                return
            }
            guard let placemarks = placemarks, placemarks.count > 0 else {
                return
            }
            let placemark = placemarks[0]
            if let location = placemark.location {
                self.centerMapOnLocation(location: location.coordinate)
                self.addAnnotationAtCoordinate(coordinate: location.coordinate)
                
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        if textField == textAddress {
            isUserInteraction = false
            let autocompleteController = GMSAutocompleteViewController()
                autocompleteController.delegate = self

                // Specify the place data types to return.
                let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                          UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.coordinate.rawValue)  | UInt(GMSPlaceField.formattedAddress.rawValue) |  UInt(GMSPlaceField.defaultFields.rawValue))!
                autocompleteController.placeFields = fields

            present(autocompleteController, animated: true, completion: nil)
           
        }
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        if textField == textAddress {
            isUserInteraction = true
           
        }
        return true
    }

    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        map.removeAnnotations(map.annotations)
        map.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if isUserInteraction {
            let center = mapView.centerCoordinate
            getAddressFromLatLon(pdblLatitude: String(center.latitude), withLongitude: String(center.longitude))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


