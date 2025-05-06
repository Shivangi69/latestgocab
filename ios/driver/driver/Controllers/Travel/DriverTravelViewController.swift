//
//  DriverTravelViewController.swift
//  Driver
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

import UIKit
import SPAlert
import MapKit
import AVFoundation

class DriverTravelViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, SlideToActionButtonDelegate, SlideToActionButtonNewDelegate {
    func didFinishNEW(identifier: String) {
        // Check which button triggered the delegate method
        if identifier == "Call" {
            if let call = Request.shared.rider?.mobileNumber,
                let url = URL(string: "tel://\(call)"),
                UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
            }
        }
        
        else if identifier == "Start" {
            LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
            Start().execute() { result in
                LoadingOverlay.shared.hideOverlayView()
                switch result {
                case .success(let response):
                    Request.shared = response
                    self.refreshScreen()
                    
                case .failure(let error):
                    error.showAlert()
                }
            }
        }
        
    else if identifier == "Arrived" {
        LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
        Arrived().execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(let response):
                Request.shared = response
                self.refreshScreen()
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
        
        else if identifier == "Stopages" {
            totalStops = (Request.shared.points.count) - 2
            
            if (Request.shared.points.count) <= 2 {
                buttonstopages.isHidden = true
                print("Not enough stops. Hiding the button.")
            } else {
               
                if currentStop <= totalStops {
                    // Increment the stop count after swipe
                    if route.count > 2 {
                        Request.shared.log = MapsUtil.encode(items: MapsUtil.simplify(items: route, tolerance: 50))
                    }
                    let currentStopPoint = route.last
                    let currentRoutePoint = Request.shared.points[currentStop] // Only send
                    let dropLocationRequest = DropLocationRequest(
                        points: Request.shared.points.map { point in
                            DropLocationRequest.pointsroute(x: point.latitude, y: point.longitude)
                        },
                        tripId: Request.shared.id ?? 0,
                        currentPoints: [
                            DropLocationRequest.currentPoints(x: currentStopPoint?.latitude ?? 0.0, y: currentStopPoint?.longitude ?? 0.0)
                               ]
                           
                    )
                    saveDropLocationAPI(dropLocationRequest: dropLocationRequest)

                    currentStop += 1
                    buttonstopages.labelText = "Stop \(currentStop) of \(totalStops) | Go to Next Stop"
                    
                    // Optionally handle when all stops are completed
                    if currentStop > totalStops {
                        print("All stops completed.")
                        // Optionally disable the button when stops are completed
                        buttonstopages.isHidden = true
                        buttonFinishSlide.isHidden = false

                     
                    }
                }
            }
        }

        
    else if identifier == "Finish" {
        
            
        if Request.shared.confirmationCode != nil {
            showConfirmationDialog()
        }
        if route.count > 2 {
            Request.shared.log = MapsUtil.encode(items: MapsUtil.simplify(items: route, tolerance: 50))
        }
        let f = FinishService(cost: Request.shared.costAfterVAT!, log: Request.shared.log, distance: Request.shared.distanceReal!, waypoints: route)
        finishTravel(finishService: f)
        playNotificationSound(soundname: "ride_finished")
    }
    else if identifier == "Cancel" {
        LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
        Cancel().execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(_):
                Request.shared.status = .DriverCanceled
                self.refreshScreen()
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
        // Add more conditions for other buttons if needed
    }
    
   
    @IBOutlet weak var labelCost: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonFinish: UIButton!
    @IBOutlet weak var buttonMessage: UIButton!
    @IBOutlet weak var buttonCall: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var buttonArrived: ColoredButton!
    @IBOutlet weak var buttonstopages: SlideToActionButton!

    @IBOutlet weak var buttonArrivedSlider: SlideToActionButton!
    @IBOutlet weak var buttonstartSlide: SlideToActionButton!
    
    @IBOutlet weak var buttonFinishSlide: SlideToActionButton!
    
    
    @IBOutlet weak var buttonCancelSLide: SlideToActionButtonNew!
    
    var currentStop = 1
    var totalStops = Int()
    

    var timer = Timer()
    var locationManager = CLLocationManager()
    var pointAnnotations: [MKPointAnnotation] = []
    var destinationMarker = MKPointAnnotation()
    var driverMarker = MKPointAnnotation()
    var route = [CLLocationCoordinate2D]()
    var distance: Double = 0.0
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.travelCanceled), name: .cancelTravel, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.requestRefresh), name: .connectedAfterForeground, object: nil)
        if let cost = Request.shared.costAfterVAT {
            labelCost.text = MyLocale.formattedCurrency(amount: cost - (Request.shared.providerShare ?? 0), currency: Request.shared.currency!)
        }
        CallView.delegate = self
        CallView.identifier = "Call"
        buttonstartSlide.delegate = self
        buttonstartSlide.identifier = "Start"
        buttonArrivedSlider.delegate = self
        buttonArrivedSlider.identifier = "Arrived"
        
        buttonstopages.delegate = self

        buttonstopages.identifier = "Stopages"
        totalStops = (Request.shared.points.count) - 2

        buttonstopages.labelText = "Stop \(currentStop) of \(totalStops) | Go to Next Stop"

        buttonCancelSLide.delegate = self
        buttonCancelSLide.identifier = "Cancel"
        
        buttonFinishSlide.delegate = self
        buttonFinishSlide.identifier = "Finish"
        map.delegate = self
        map.layoutMargins = UIEdgeInsets(top: 50, left: 0, bottom: 300, right: 0)
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.addSubview(blurEffectView)
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10)).cgPath
        self.backgroundView.layer.mask = maskLayer
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 50
            //     locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        self.navigationItem.hidesBackButton = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onEachSecond), userInfo: nil, repeats: true)
    }
    func didFinish(identifier: String) {
            // Check which button triggered the delegate method
            if identifier == "Call" {
                if let call = Request.shared.rider?.mobileNumber,
                    let url = URL(string: "tel://\(call)"),
                    UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                }
            } else if identifier == "Start" {
                LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
                Start().execute() { result in
                    LoadingOverlay.shared.hideOverlayView()
                    switch result {
                    case .success(let response):
                        Request.shared = response
                        self.refreshScreen()
                    case .failure(let error):
                        error.showAlert()
                    }
                }
            }
        
        else if identifier == "Arrived" {
            LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
                    Arrived().execute() { result in
                LoadingOverlay.shared.hideOverlayView()
                switch result {
                case .success(let response):
                    Request.shared = response
                    self.refreshScreen()
                    
                case .failure(let error):
                    error.showAlert()
                }
            }
        }
    
        
            else if identifier == "Stopages" {
                totalStops = (Request.shared.points.count) - 2
                
                if (Request.shared.points.count) <= 2 {
                    buttonstopages.isHidden = true
                    print("Not enough stops. Hiding the button.")
                } else {
                    
                    if currentStop <= totalStops {
                        // Increment the stop count after swipe
                        if route.count > 2 {
                            Request.shared.log = MapsUtil.encode(items: MapsUtil.simplify(items: route, tolerance: 50))
                        }
//                      
                        let currentStopPoint = route.last
                        let currentRoutePoint = Request.shared.points[currentStop] // Only send one point at a time

                        let dropLocationRequest = DropLocationRequest(
                            points: [
                                   DropLocationRequest.pointsroute(x: currentRoutePoint.latitude, y: currentRoutePoint.longitude)
                               ],
                            tripId: Request.shared.id ?? 0,
                            currentPoints: [
                                DropLocationRequest.currentPoints(x: currentStopPoint?.latitude ?? 0.0, y: currentStopPoint?.longitude ?? 0.0)
                                   ]
                               
                        )
                        saveDropLocationAPI(dropLocationRequest: dropLocationRequest)

                        currentStop += 1
                        buttonstopages.labelText = "Stop \(currentStop) of \(totalStops) | Go to Next Stop"
                        
                        // Optionally handle when all stops are completed
                        if currentStop > totalStops {
                            print("All stops completed.")
                            // Optionally disable the button when stops are completed
                            buttonstopages.isHidden = true
                            buttonFinishSlide.isHidden = false

                         
                        }
                    }
                }
                
            }
        
        else if identifier == "Finish" {
            if Request.shared.confirmationCode != nil {
                showConfirmationDialog()
            }
            if route.count > 2 {
                Request.shared.log = MapsUtil.encode(items: MapsUtil.simplify(items: route, tolerance: 50))
            }
            let f = FinishService(cost: Request.shared.costAfterVAT!, log: Request.shared.log, distance: Request.shared.distanceReal!, waypoints: route)
            finishTravel(finishService: f)
            playNotificationSound(soundname: "ride_finished")
        }
                
        else if identifier == "Cancel" {
            LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
            Cancel().execute() { result in
                LoadingOverlay.shared.hideOverlayView()
                switch result {
                case .success(_):
                    Request.shared.status = .DriverCanceled
                    self.refreshScreen()
                    
                case .failure(let error):
                    error.showAlert()
                }
            }
        }
        
            // Add more conditions for other buttons if needed
        }
    
    
    func drawRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
           let sourcePlacemark = MKPlacemark(coordinate: source)
           let destinationPlacemark = MKPlacemark(coordinate: destination)
           
           let sourceItem = MKMapItem(placemark: sourcePlacemark)
           let destinationItem = MKMapItem(placemark: destinationPlacemark)
           
           let request = MKDirections.Request()
           request.source = sourceItem
           request.destination = destinationItem
           request.transportType = .automobile
           
           let directions = MKDirections(request: request)
           directions.calculate { (response, error) in
               guard let response = response else {
                   if let error = error {
                       print("Error calculating directions: \(error.localizedDescription)")
                   }
                   return
               }
               let route = response.routes[0]
               self.map.addOverlay(route.polyline, level: .aboveRoads)
           }
       }

       // Function to remove all overlays (polylines) from the map
       func removeRoutes() {
           let overlays = map.overlays
           map.removeOverlays(overlays)
       }

       // MKMapViewDelegate method to render overlays (polylines)
       func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
           if let polyline = overlay as? MKPolyline {
               let renderer = MKPolylineRenderer(polyline: polyline)
               renderer.strokeColor = UIColor.black
               renderer.lineWidth = 2.0
               return renderer
           }
           return MKOverlayRenderer()
       }

       // Function to update route display
       private func updateRouteDisplay() {
           removeRoutes() // Clear previous routes
           if let driverLocation = locationManager.location?.coordinate,
              let riderLocation = Request.shared.points.first {
               drawRoute(from: driverLocation, to: riderLocation)
           }
           if Request.shared.status == .Started {
               for i in 0..<Request.shared.points.count - 1 {
                   drawRoute(from: Request.shared.points[i], to: Request.shared.points[i + 1])
               }
           }
       }

    
   
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateRouteDisplay()

        self.requestRefresh()
    }
    
    @IBAction func onStartTapped(_ sender: UIButton) {
        LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
        Start().execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(let response):
                Request.shared = response
                self.refreshScreen()
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    func playNotificationSound(soundname: String) {
           guard let url = Bundle.main.url(forResource: soundname, withExtension: "mp3") else { return }
           do {
               audioPlayer = try AVAudioPlayer(contentsOf: url)
               audioPlayer?.play()
           } catch let error {
               print("Error playing notification sound: \(error.localizedDescription)")
           }
       }
    @IBAction func onFinishTapped(_ sender: UIButton) {
        if Request.shared.confirmationCode != nil {
            showConfirmationDialog()
        }
        if route.count > 2 {
            Request.shared.log = MapsUtil.encode(items: MapsUtil.simplify(items: route, tolerance: 50))
        }
        let f = FinishService(cost: Request.shared.costAfterVAT!, log: Request.shared.log, distance: Request.shared.distanceReal!, waypoints: route)
        finishTravel(finishService: f)
        playNotificationSound(soundname: "ride_finished")
    }
    
    func showConfirmationDialog() {
        let question = UIAlertController(title: "Confirmation", message: "Finishing this service needs confirmation code delivered to user. Please enter it in following field:", preferredStyle: .alert)
        question.addAction(UIAlertAction(title: "OK", style: .default) { action in
            let code = question.textFields![0].text!
            let f = FinishService(cost: Request.shared.costAfterVAT!, distance: Request.shared.distanceReal!, confirmationCode: Int(code)!, waypoints: self.route)
            self.finishTravel(finishService: f)
        })
        question.addTextField() { textField in
            textField.placeholder = "code"
        }
        self.present(question, animated: true)
    }
    
    func finishTravel(finishService: FinishService) {
        timer.invalidate()
        LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
        Finish(confirmationCode: finishService.confirmationCode, distance: finishService.distance ?? 0, log: finishService.log ?? "", waypoints: route).execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(let response):
                Request.shared.status = response.status ? Request.Status.Finished : Request.Status.WaitingForPostPay
                if response.status {
                    let alert = UIAlertController(title: "Message", message: "Payment has been settled and credit has been added to your wallet.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                        self.navigationController?.popViewController(animated: true)
                    })
                    self.present(alert, animated: true)
                } else {
                    let vc = Bundle.main.loadNibNamed("WaitingForPayment", owner: self, options: nil)?.first as! WaitingForPaymentViewController
                    vc.onDone = { b in
                        self.requestRefresh()
                    }
                    self.present(vc, animated: true)
                }
                
            case .failure(let error):
                if error.status == ErrorStatus.ConfirmationCodeRequired {
                    self.showConfirmationDialog()
                } else {
                    error.showAlert()
                }
            }
        }
    }
    
    
    @IBAction func onButtonArrivedTapped(_ sender: ColoredButton) {
        LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
        Arrived().execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(let response):
                Request.shared = response
                self.refreshScreen()
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
    @IBAction func onMessageTapped(_ sender: UIButton) {
        let vc = ChatViewController()
        vc.sender = Request.shared.rider!
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func onCancelTapped(_ sender: UIButton) {
        LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
        Cancel().execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(_):
                Request.shared.status = .DriverCanceled
                self.refreshScreen()
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
    @objc private func requestRefresh() {
        LoadingOverlay.shared.showOverlay(view: self.navigationController?.view)
        GetCurrentRequestInfo().execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(let response):
                Request.shared = response.request
                self.refreshScreen()
                
            case .failure(_):
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func refreshScreen(travel: Request = Request.shared) {
        switch travel.status! {
        case .RiderCanceled, .DriverCanceled:
            let alert = UIAlertController(title: "Success", message: "Service Has Been Canceled.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Allright!", style: .default) { action in
                self.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
            if (travel.status == .RiderCanceled ){
                playNotificationSound(soundname: "ride_cancel")
                
            }
            break;
            
        case .DriverAccepted:
            buttonFinish.isHidden = true
            buttonFinishSlide.isHidden = true
            buttonstopages.isHidden = true
            
            buttonStart.isHidden = true
            buttonstartSlide.isHidden = true
            
            let ann = MKPointAnnotation()
            ann.coordinate = travel.points[0]
            ann.title =  travel.addresses[0]
            pointAnnotations.append(ann)
            map.addAnnotation(ann)
            if map.annotations.count > 1 {
                map.showAnnotations(map.annotations, animated: true)
            } else {
                map.setCenter(map.annotations[0].coordinate, animated: true)
            }
            playNotificationSound(soundname: "notification")
            break;
            
        case .Arrived:
            buttonStart.isHidden = false
            buttonstartSlide.isHidden = false
            buttonstopages.isHidden = true
            
            buttonArrived.isHidden = true
            buttonArrivedSlider.isHidden = true
            
            
        case .Started:
            buttonMessage.isHidden = true
            buttonCall.isHidden = true
            buttonCancel.isHidden = true
        
            buttonCancelSLide.isHidden = true
            
            buttonStart.isHidden = true
            buttonstartSlide.isHidden = true
            //            buttonstopages.isHidden = false
            if ((Request.shared.points.count) - 2) >= 2{
                buttonstopages.isHidden = false
                buttonFinishSlide.isHidden = true
            }
        
            else if currentStop >= ((Request.shared.points.count) - 2){
                buttonFinishSlide.isHidden = false
                buttonstopages.isHidden = true
                
            }
            
            
            //          buttonFinishSlide.isHidden = false
            //          buttonFinish.isHidden = false
            buttonArrived.isHidden = true
            buttonArrivedSlider.isHidden = true
            
            if pointAnnotations.count > 0 {
                for point in pointAnnotations {
                    map.removeAnnotation(point)
                }
            }
            for (index, point) in travel.points.dropFirst().enumerated() {
                let ann = MKPointAnnotation()
                ann.coordinate = point
                ann.title = travel.addresses[index + 1]
                pointAnnotations.append(ann)
                map.addAnnotation(ann)
            }
            if map.annotations.count > 1 {
                map.showAnnotations(map.annotations, animated: true)
            } 
            else {
                map.setCenter(map.annotations[0].coordinate, animated: true)
            }
            break;
            
        case .WaitingForPostPay:
            let vc = Bundle.main.loadNibNamed("WaitingForPayment", owner: self, options: nil)?.first as! WaitingForPaymentViewController
            vc.onDone = { b in
                self.requestRefresh()
            }
            self.present(vc, animated: true)
            
            
        case .Finished, .WaitingForReview:
            SPAlert.present(title: "Paid!", preset: .card)
            self.navigationController?.popViewController(animated: true)
            
        default:
            let alert = UIAlertController(title: "Error", message: "Unkown Status: \(travel.status!.rawValue)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Allright!", style: .default) { action in
                self.navigationController?.popViewController(animated: true)
            })
            self.present(alert, animated: true)
        }
        
        updateRouteDisplay()

    }
    
    @objc func travelCanceled() {
        Request.shared.status = .RiderCanceled
        refreshScreen()
    }
    
    enum MarkerType: String {
        case pickup = "pickup"
        case dropoff = "dropOff"
        case driver = "driver"
        case Stop = "stop"

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKPointAnnotation else { return nil }
        print(annotation.title ?? "")

        var identifier: MarkerType

        if pointAnnotations.count > 2 {
            if pointAnnotations.first == annotation {
                identifier = .pickup
            } else if pointAnnotations.last == annotation {
                identifier = .dropoff
            } else if pointAnnotations.contains(annotation) {
                identifier = .Stop
            } else {
                identifier = .driver
            }
        } else {
            if pointAnnotations.first == annotation {
                identifier = .pickup
            } else if pointAnnotations.last == annotation {
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
        //
        guard let index = pointAnnotations.firstIndex(of: annotation) else { return nil }
        let stopNumber = index // Since the first is pickup and the last is dropoff
print("stopNumber",stopNumber)
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
    @objc func annotationTapped() {
        openNavigationMenu(location: map.selectedAnnotations.last!.coordinate)
    }
    
    func openNavigationMenu(location: CLLocationCoordinate2D) {
        let alert = UIAlertController(title: "Navigation", message: "Select App to navigate with", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { action in
            if let url = URL(string: "http://maps.apple.com/?q=\(location.latitude),\(location.longitude)&z=10&t=s"),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { action in
            if let url = URL(string: "comgooglemaps://?daddr=\(location.latitude),\(location.longitude)&directionsmode=driving"),
                UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Waze", style: .default, handler: { action in
            if let url = URL(string: "https://www.waze.com/ul?ll=\(location.latitude),\(location.longitude)&navigate=yes"),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Yandex.Maps", style: .default, handler: { action in
            if let url = URL(string: "yandexmaps://maps.yandex.com/?ll=\(location.latitude),\(location.longitude)&z=12"),
                UIApplication.shared.canOpenURL(URL(string: "yandexmaps://")!) {
                UIApplication.shared.open(url)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onEachSecond() {
        let now = Date()
        let etaInterval = Request.shared.startTimestamp != nil ? (Request.shared.startTimestamp! / 1000) + Double(Request.shared.durationBest!) : Request.shared.etaPickup! / 1000
        let etaTime = Date(timeIntervalSince1970: etaInterval)
        if etaTime <= now {
            labelTime.text = NSLocalizedString("Soon!", comment: "When driver is coming later than expected.")
        } else {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .short
            labelTime.text = formatter.string(from: now, to: etaTime)
        }
        recalculateCost()
        //updateRouteDisplay()

        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        if route.count > 0 {
            let distance = Int(userLocation.distance(from: CLLocation(latitude: route[route.count - 1].latitude, longitude: route[route.count - 1].longitude)))
            Request.shared.distanceReal! += distance
        } else {
            route.append(userLocation.coordinate)
            Request.shared.distanceReal = 0
        }
        LocationUpdate(jwtToken: UserDefaultsConfig.jwtToken!, location: userLocation.coordinate, inTravel: true).execute() { _ in
            self.refreshScreen()
        }
        route.append(userLocation.coordinate)
        driverMarker.coordinate = userLocation.coordinate
        map.addAnnotation(driverMarker)
        map.showAnnotations(pointAnnotations, animated: true)
    }
    
    func recalculateCost() {
        if let service = Request.shared.service , service.feeEstimationMode == .Dynamic {
            var cost = 0.0
            if Request.shared.status == Request.Status.Started {
                let duration = (Date().timeIntervalSince1970 - (Double(Request.shared.startTimestamp!) / 1000)) / 60
                cost = Request.shared.costAfterVAT ?? 0.0//service.baseFare + (distance / 100 * service.perHundredMeters) + (duration * service.perMinuteDrive)
            }
            labelCost.text = String(format: "~\(MyLocale.formattedCurrency(amount: cost, currency: Request.shared.currency!))")
        }
    }
    
    @IBOutlet weak var CallView: SlideToActionButtonNew!
    
    
    @IBAction func onCallTouched(_ sender: UIButton) {
        if let call = Request.shared.rider?.mobileNumber,
            let url = URL(string: "tel://\(call)"),
            UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
        }
    }
    
    func saveDropLocationAPI(dropLocationRequest: DropLocationRequest) {
        let user = try! Rider(from: UserDefaultsConfig.user!)
        let token = UserDefaultsConfig.jwtToken ?? ""
        
        let urlString = Config.Backend + "trips/save/drop-location"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(dropLocationRequest)
            request.httpBody = jsonData
            
            // Debugging: Print JSON payload
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Request JSON: \(jsonString)")
            }
            
        } catch {
            print("Error encoding request data: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    print("Invalid response, status code: \(httpResponse.statusCode)")
                    if let data = data {
                        // Debugging: Print response data
                        let responseString = String(data: data, encoding: .utf8)
                        print("Response data: \(responseString ?? "No response data")")
                    }
                    return
                }
            }
            
            print("Drop location saved successfully!")
        }
        
        task.resume()
    }
    
//    func saveDropLocationAPI(dropLocationRequest: DropLocationRequest) {
//        let user = try! Rider(from: UserDefaultsConfig.user!)
//        let token = UserDefaultsConfig.jwtToken ?? ""
//        
//        let urlString = Config.Backend +  "trips/save/drop-location"
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let jsonData = try JSONEncoder().encode(dropLocationRequest)
//            request.httpBody = jsonData
//        } catch {
//            print("Error encoding request data: \(error)")
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                print("Invalid response")
//                return
//            }
//
//            print("Drop location saved successfully!")
//        }
//        
//        task.resume()
//    }
}
struct DropLocationRequest: Codable {
    let points: [pointsroute]
    let tripId: Int
    let currentPoints: [currentPoints]
    
    
    struct pointsroute: Codable {
        let x: Double
        let y: Double
    }
    struct currentPoints: Codable {
        let x: Double
        let y: Double
    }
}
