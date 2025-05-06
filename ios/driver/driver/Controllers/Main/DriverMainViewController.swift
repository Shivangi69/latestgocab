//
//  DriverMainViewController.swift
//  Driver
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation
import iCarousel

class DriverMainViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var buttonStatus: UISwitch!
    @IBOutlet weak var requestsList: iCarousel!
    @IBOutlet weak var map: MKMapView!
    var idArr = NSMutableArray()
    var requests : [Request] = []
    var locationManager = CLLocationManager()
    var audioPlayer: AVAudioPlayer?
    func playNotificationSound(soundname: String) {
           guard let url = Bundle.main.url(forResource: soundname, withExtension: "mp3") else { return }
           do {
               audioPlayer = try AVAudioPlayer(contentsOf: url)
               audioPlayer?.play()
           } catch let error {
               print("Error playing notification sound: \(error.localizedDescription)")
           }
       }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onRequestReceived), name: .requestReceived, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onRequestCanceled), name: .requestCanceled, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshRequests), name: .connectedAfterForeground, object: self)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        requestsList.dataSource = self
        requestsList.delegate = self
        requestsList.type = .rotary
        idArr.removeAllObjects()

        if let declineRequests = UserDefaults.standard.array(forKey: "DeclineRequests") {
            idArr.addObjects(from: declineRequests)
        }

        GetCurrentRequestInfo().execute() { result in
            switch result {
            case .success(let response):
                if response.request.status! == .WaitingForReview {
                    return
                }
                Request.shared = response.request
                self.performSegue(withIdentifier: "startTravel", sender: nil)
                
            case .failure(_):
                self.refreshRequests()
            }
        }
    }
    
    @objc func refreshRequests() {
        GetAvailableRequests().execute() { result in
            switch result {
            case .success(let response):
                self.buttonStatus.isOn = true
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.startUpdatingLocation()
                self.requests = response
                self.requestsList.reloadData()
                
            case .failure(_):
                
                self.buttonStatus.isOn = true
                
            }
        }
    }
    
    @IBAction func onDriverStatusClicked(_ sender: UISwitch) {
        buttonStatus.isEnabled = false
        if !sender.isOn {
            self.locationManager.stopUpdatingLocation()
        }
        UpdateStatus(turnOnline: sender.isOn).execute() { result in
            self.buttonStatus.isEnabled = true
            switch result {
            case .success(_):
                break
                
            case .failure(let error):
                self.buttonStatus.isOn = !self.buttonStatus.isOn
                error.showAlert()
            }
            if sender.isOn {
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.startUpdatingLocation()
            } else {
                self.requests = []
                self.requestsList.reloadData()
            }
        }
    }
    
    
    @IBAction func onMenuClicked(_ sender: Any) {
        NotificationCenter.default.post(name: .menuClicked, object: nil)
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let userLocation:CLLocation = locations[0] as CLLocation
//        LocationUpdate(jwtToken: UserDefaultsConfig.jwtToken!, location: userLocation.coordinate).execute() { _ in
//            self.refreshRequests()
//        }
//        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//        map.setRegion(region, animated: true)
//    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let jwtToken = UserDefaultsConfig.jwtToken else {
            print("JWT token is nil")
            return
        }

        let userLocation: CLLocation = locations[0]
        LocationUpdate(jwtToken: jwtToken, location: userLocation.coordinate).execute { _ in
            self.refreshRequests()
        }

        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        map.setRegion(region, animated: true)
    }
    
    @objc func onRequestReceived(_ notification: Notification) {
        if let request = notification.object as? Request {
            requests.append(request)
            requestsList.reloadData()
        }
    }
    
    @objc func onRequestCanceled(_ notification: Notification) {
        refreshRequests()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension DriverMainViewController: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return requests.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let travel = requests[requests.index(requests.startIndex, offsetBy: index)]
       
        if let travelId = travel.id, (!idArr.contains(travelId)) {
            playNotificationSound(soundname: "new_ride")
            let vc = Bundle.main.loadNibNamed("RequestCard", owner: self, options: nil)?[0] as! RequestCard
            
            vc.request = travel

            vc.labelPickupLocation.text = travel.addresses.first
            vc.labelDropOffLocation.text = travel.addresses.last
            let distanceDriver = CLLocation.distance(from: map.userLocation.coordinate, to: travel.points[0])
            vc.labelFromYou.text = MKDistanceFormatter().string(fromDistance: distanceDriver)
            vc.labelDistance.text = MKDistanceFormatter().string(fromDistance: Double(travel.distanceBest!))
            vc.labelCost.text = MyLocale.formattedCurrency(amount: (travel.costBest ?? 0) - (travel.providerShare ?? 0), currency: travel.currency!)
            vc.delegate = self
            vc.layer.cornerRadius = 8
            vc.layer.shadowOpacity = 0.2
            vc.layer.shadowOffset = CGSize(width: 0, height: 0)
            vc.layer.shadowRadius = 4.0
            let shadowRect: CGRect = vc.bounds
            let _ = vc.constraintUser.setConstant(constant: CGFloat((distanceDriver.binade - Double(travel.distanceBest!)) / (distanceDriver + Double(travel.distanceBest!)) * 100))
            vc.layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
            return vc
        }
        
        // Return a default UIView if the condition is not met
        return UIView()
    }

    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.1
        }
        return value
    }
}
extension DriverMainViewController: DriverRequestCardDelegate {
    
    
    func accept(request: Request) {
        LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
        AcceptOrder(requestId: request.id!).execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(let response):
                self.requests.removeAll()
                self.requestsList.reloadData()
                Request.shared = response
                self.performSegue(withIdentifier: "startTravel", sender: nil)
                
            case .failure(let error):
                if error.status == .OrderAlreadyTaken {
                    self.refreshRequests()
                }
                error.showAlert()
            }
        }
    }
    
    func reject(request: Request) {
        requests.removeAll() {req in return req.id == request.id }
        requestsList.reloadData()
        
        idArr.add(request.id!)
        UserDefaults.standard.set(idArr, forKey: "DeclineRequests")
    }
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
    
    func setConstant(constant:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
