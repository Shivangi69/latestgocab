import UIKit
import MapKit
import SPAlert
import Kingfisher
import AVFoundation

class TravelViewController: UIViewController, CouponsViewDelegate, MKMapViewDelegate, SlideToActionButtonNewDelegate, SlideToActionButtonDelegate {
    @IBOutlet weak var Agency_image: UIImageView!
    @IBOutlet weak var AgencyNameText: UILabel!
    @IBOutlet weak var CarNameAndNum: UILabel!
    @IBOutlet weak var Agency_View: UIView!
    @IBOutlet weak var Agency_Address: UILabel!
    @IBOutlet weak var Agency_Year: UILabel!
    
    @IBOutlet weak var phone_number: UILabel!
    @IBOutlet weak var Full_name: UILabel!
    
    @IBAction func okAction(_ sender: Any) {
        Agency_View.isHidden = true
    }
    @IBOutlet weak var emai_text: UILabel!
    func didFinishNEW(identifier: String) {
        if identifier == "Call" {
            if let call = Request.shared.driver?.mobileNumber, let url = URL(string: "tel://\(call)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    
   
    else if identifier == "Cancel" {
        Cancel().execute() { result in
            switch result {
            case .success(_):
                Request.shared.status = .RiderCanceled
                self.refreshScreen(driverLocation: nil)
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    }
    
    @IBAction func showAgencyDetail(_ sender: Any) {
        Agency_View.isHidden = false
    }
    func didFinish(identifier: String) {
            // Check which button triggered the delegate method
            if identifier == "Call" {
                if let call = Request.shared.driver?.mobileNumber, let url = URL(string: "tel://\(call)"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        
       
        else if identifier == "Cancel" {
            Cancel().execute() { result in
                switch result {
                case .success(_):
                    Request.shared.status = .RiderCanceled
                    self.refreshScreen(driverLocation: nil)
                    
                case .failure(let error):
                    error.showAlert()
                }
            }
        }
        
            // Add more conditions for other buttons if needed
        }
    
    @IBOutlet weak var ToAdd: UILabel!
    @IBOutlet weak var FromAdd: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var labelCost: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var buttonCall: ColoredButton!
    @IBOutlet weak var buttonMessage: ColoredButton!
    @IBOutlet weak var buttonCancel: ColoredButton!
    @IBOutlet weak var buttonPay: ColoredButton!
    
    @IBOutlet weak var buttonCallSlide: SlideToActionButtonNew!
    @IBOutlet weak var buttonCancelSlide: SlideToActionButton!
    var pickupMarker = MKPointAnnotation()
    var destinationMarkers: [MKPointAnnotation] = []
    var driverMarker = MKPointAnnotation()
    var routeOverlay: MKPolyline?
    var timer: Timer!
    @IBOutlet weak var confirmationBarButton: UIBarButtonItem!
    @IBOutlet weak var tabBar: UISegmentedControl!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var viewStatistics: UIView!
    @IBOutlet weak var viewDriver: UIStackView!
    @IBOutlet weak var textDriverName: UILabel!
    @IBOutlet weak var textPlateNumber: UILabel!
    @IBOutlet weak var imgDriver: UIImageView!
    @IBOutlet weak var upperStackView: UIStackView!
    @IBOutlet weak var star1ImageView: UIImageView!
    @IBOutlet weak var star2ImageView: UIImageView!
    @IBOutlet weak var star3ImageView: UIImageView!
    @IBOutlet weak var star4ImageView: UIImageView!
    @IBOutlet weak var star5ImageView: UIImageView!
    
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onArrived), name: .arrived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onServiceStarted), name: .serviceStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onServiceCanceled), name: .serviceCanceled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onServiceFinished), name: .serviceFinished, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onTravelInfoReceived), name: .travelInfoReceived, object: nil)
       // NotificationCenter.default.addObserver(self, selector:#selector(self.requestRefresh), name: .connectedAfterForeground, object: nil)
        textDriverName.text = "\(Request.shared.driver?.firstName ?? "- ") \(Request.shared.driver?.lastName ?? "")"
        upperStackView.addBorder(color: .black, backgroundColor: .white, thickness: 1)
        var details = [String]()
        if let carName = Request.shared.driver?.car?.title {
            details.append(carName)
        }
        if let carColor = Request.shared.driver?.carColor {
            details.append(carColor)
        }
        if let carPlate = Request.shared.driver?.carPlate {
            details.append(carPlate)
        }
        textPlateNumber.text = details.joined(separator: ", ")
        tabBar.addTarget(self, action: #selector(selectedTabItem), for: .valueChanged)
        map.layoutMargins = UIEdgeInsets(top: 50, left: 0, bottom: 290, right: 0)
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.addSubview(blurEffectView)
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10)).cgPath
        self.backgroundView.layer.mask = maskLayer
        driverMarker = MKPointAnnotation()
        map.delegate = self
        self.navigationItem.hidesBackButton = true
        if Request.shared.service?.canEnableVerificationCode == false {
            self.navigationItem.rightBarButtonItem = nil
        }
        if let cost = Request.shared.costAfterVAT {
            self.labelCost.text = MyLocale.formattedCurrency(amount: cost, currency: Request.shared.currency!)
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onEachSecond), userInfo: nil, repeats: true)
        
        buttonCallSlide.delegate = self
        buttonCallSlide.identifier = "Call"
        buttonCancelSlide.delegate = self
        buttonCancelSlide.identifier = "Cancel"
//
        FromAdd.text = UserDefaults.standard.string(forKey: "LOCA")
//        ToAdd = Request.shared.addresses[1]
        ToAdd.text = UserDefaults.standard.string(forKey: "LOCB")

        fetchData()
        
    }
    
    @IBOutlet weak var AGencyName: UILabel!
    @objc func selectedTabItem(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            viewDriver.isHidden = true
            viewStatistics.isHidden = false
        } else {
            viewDriver.isHidden = false
            viewStatistics.isHidden = true
        }
    }
    
    @IBAction func onMessageTapped(_ sender: UIButton) {
        let vc = ChatViewController()
        vc.sender = Request.shared.driver!
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.requestRefresh()
    }
    
    @objc func onEachSecond() {
        let now = Date()
       
        //let etaInterval = Request.shared.startTimestamp != nil ? (Request.shared.startTimestamp! / 1000) + Double(Request.shared.durationBest!) : Request.shared.etaPickup! / 1000
        let startTimestamp = Request.shared.startTimestamp ?? 0
        let durationBest = Request.shared.durationBest ?? 0
        let etaPickup = Request.shared.etaPickup ?? 0

        let etaInterval = startTimestamp != 0 ? (Double(startTimestamp) / 1000) + Double(durationBest) : Double(etaPickup) / 1000

        let etaTime = Date(timeIntervalSince1970: etaInterval)
        if etaTime <= now {
            if Request.shared.status == .Arrived {
                labelTime.text = NSLocalizedString("Arrived!", comment: "Driver Arrived text instead of time.")
            } else {
                labelTime.text = NSLocalizedString("Soon!", comment: "When driver is coming later than expected.")
            }
            
        } else {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .short
            labelTime.text = formatter.string(from: now, to: etaTime)
        }
    }
    var audioPlayer: AVAudioPlayer?

    @objc private func requestRefresh() {
        GetCurrentRequestInfo().execute() { result in
            switch result {
            case .success(let response):
                Request.shared = response.request
                self.refreshScreen(driverLocation: response.driverLocation)
                
            case .failure(_):
                self.navigationController?.popViewController(animated: false)
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

//    private func refreshScreen(travel: Request = Request.shared, driverLocation: CLLocationCoordinate2D?) {
//        if let cost = Request.shared.costAfterVAT {
//            self.labelCost.text = MyLocale.formattedCurrency(amount: cost, currency: Request.shared.currency!)
//        }
//        if let driverImage = travel.driver?.media?.address {
//            let processor = DownsamplingImageProcessor(size: imgDriver.intrinsicContentSize) |> RoundCornerImageProcessor(cornerRadius: imgDriver.intrinsicContentSize.width / 2)
//            let url = URL(string: Config.Backend + driverImage.replacingOccurrences(of: " ", with: "%20"))
//            imgDriver.kf.setImage(with: url, placeholder: UIImage(named: "Nobody"), options: [
//                .processor(processor),
//                .scaleFactor(UIScreen.main.scale),
//                .transition(.fade(0.5)),
//                .cacheOriginalImage
//            ], completionHandler: { result in
//                switch result {
//                case .success(let value):
//                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
//                case .failure(let error):
//                    print("Job failed: \(error.localizedDescription)")
//                }
//            })
//        }
//        switch travel.status! {
//        case .RiderCanceled, .DriverCanceled:
//            let alert = UIAlertController(title: NSLocalizedString("Message", comment: ""), message: NSLocalizedString("Service Has Been Canceled.", comment: ""), preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: NSLocalizedString("Alright!", comment: ""), style: .default) { action in
//                _ = self.navigationController?.popViewController(animated: true)
//            })
//            present(alert, animated: true)
//            if (travel.status == .DriverCanceled ){
//                playNotificationSound(soundname: "ride_cancel")
//
//            }
//            break
//
//        case .DriverAccepted:
//            pickupMarker.coordinate = travel.points[0]
//            map.addAnnotation(pickupMarker)
//            if let _location = driverLocation {
//                driverMarker.coordinate = _location
//                map.addAnnotation(driverMarker)
//                map.showAnnotations([pickupMarker, driverMarker], animated: true)
//                showRoute(from: pickupMarker.coordinate, to: driverMarker.coordinate) // Show route between pickup and driver
//            } else {
//                let region = MKCoordinateRegion(center: travel.points[0], latitudinalMeters: 1000, longitudinalMeters: 1000)
//                map.setRegion(region, animated: true)
//            }
//            playNotificationSound(soundname: "notification")
//            break
//
//        case .Arrived:
//            SPAlert.present(title: "Driver has arrived", preset: .flag)
//            playNotificationSound(soundname: "driver_arrived")
//
//            break
//
//        case .Started:
//            buttonCall.isHidden = true
//            buttonMessage.isHidden = true
//            buttonCancel.isHidden = true
//            map.removeAnnotation(pickupMarker)
//            for (index, point) in travel.points.enumerated() {
//                if index == 0 {
//                    continue;
//                }
//                let p = MKPointAnnotation()
//                p.coordinate = point
//                destinationMarkers.append(p)
//                map.addAnnotation(p)
//            }
//            if driverLocation != nil || destinationMarkers.count > 1 {
//                if(driverLocation != nil) {
//                    driverMarker.coordinate = driverLocation!
//                    map.addAnnotation(driverMarker)
//                    destinationMarkers.append(driverMarker)
//                    map.showAnnotations(destinationMarkers, animated: true)
//                    destinationMarkers.removeLast()
//                } else {
//                    map.showAnnotations(destinationMarkers, animated: true)
//                }
//            } else {
//                let region = MKCoordinateRegion(center: travel.points[1], latitudinalMeters: 1000, longitudinalMeters: 1000)
//                map.setRegion(region, animated: true)
//            }
//            if let firstDestination = travel.points.first {
//                showRoute(from: driverMarker.coordinate, to: firstDestination) // Show route between driver and first destination
//            }
//            playNotificationSound(soundname: "ride_start")
//
//            break
//
//        case .WaitingForPostPay,.DriverMarkedPaymentNotReceived:
//            if travel.service?.paymentMethod == .OnlyCash {
//                let alert = UIAlertController(title: NSLocalizedString("Payment", comment: ""), message: NSLocalizedString("Service Has Been finished and payment is waiting to be settled.", comment: ""), preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: NSLocalizedString("Alright!", comment: ""), style: .default) { action in
//                    self.requestRefresh()
//                })
//            } else {
//                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Wallet") as? WalletViewController {
//                    vc.amount = Request.shared.costAfterVAT
//                    vc.currency = Request.shared.currency
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
//
//            break
//
//        case .WaitingForReview:
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let controller = storyboard.instantiateViewController(withIdentifier: "finishedViewController")
//            self.navigationController?.pushViewController(controller, animated: false)
//            break
//
//        case .Finished:
//            SPAlert.present(title: NSLocalizedString("Done!", comment: ""), preset: .done)
//
//            self.navigationController?.popViewController(animated: true)
//
//        default:
//            let alert = UIAlertController(title: "Error", message: "Unknown status: \(travel.status!.rawValue)", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Allright!", style: .default) { action in
//                _ = self.navigationController?.popViewController(animated: true)
//            })
//            self.present(alert, animated: true)
//        }
//    }
    
    
    

//    func fetchData() {
//        // API endpoint URL
////        guard let url = URL(string: "https://example.com/api/data") else {
////            print("Invalid URL")
////            return
////        }
//        let id = Request.shared.driver?.id
//        var str  = String()
//        str = "\(id ?? 0)"
//        let  url = URL(string: Config.Backend + "driver/" + str)!
//
//        // Create URLRequest with the URL
//        var request = URLRequest(url: url)
//
//        // Add Bearer token to the request header
//        let token =  UserDefaultsConfig.jwtToken
//        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
//
//        // Create URLSession
//        let session = URLSession.shared
//
//        // Create data task to fetch data from the API
//        let task = session.dataTask(with: request) { data, response, error in
//            // Check for errors
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//
//            // Check if there's a response
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("No HTTP response")
//                return
//            }
//
//            // Check the status code
//            guard (200...299).contains(httpResponse.statusCode) else {
//                print("HTTP Error: \(httpResponse.statusCode)")
//                return
//            }
//
//            // Check if data is received
//            guard let data = data else {
//                print("No data received")
//                return
//            }
////            if let jsonData = jsonString.data(using: .utf8) {
//                do {
////                     Parse JSON data into a dictionary
//                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                       let data = jsonObject["data"] as? [String: Any],
//                       let driver = data["driver"] as? [String: Any],
//                       let assignedVehicle = driver["assignedVehicle"] as? [String: Any],
//                        let Agency = driver["agency"] as? [String: Any] {
//
//                        // Extract car details
//                        let licensePlateNumber = assignedVehicle["license_plate_number"] as? String ?? "N/A"
//                        let make = assignedVehicle["make"] as? String ?? "N/A"
//                        let model = assignedVehicle["model"] as? String ?? "N/A"
//                        let color = assignedVehicle["color"] as? String ?? "N/A"
//                        let vehicleType = assignedVehicle["vehicle_type"] as? String ?? "N/A"
//                        let notes = assignedVehicle["notes"] as? String ?? "N/A"
//                        let agency_name = Agency["agency_name"] as? String ?? "N/A"
//
//                        // Print car details
//                        print("License Plate Number: \(licensePlateNumber)")
//                        print("Make: \(make)")
//                        print("Model: \(model)")
//                        print("Color: \(color)")
//                        print("Vehicle Type: \(vehicleType)")
//                        print("Notes: \(notes)")
//                        self.CarNameAndNum.text = make + color + model + vehicleType + licensePlateNumber
//
//                        self.AGencyName.text = agency_name
//
//                   }
//                } catch {
//                    print("Error parsing JSON: \(error.localizedDescription)")
//                }
//           // }
//            // Decode the JSON data
////            do {
////                let decodedData = try JSONSerialization.jsonObject(with: data, options: [])
////                print(decodedData)
////                // Handle the decoded data
////               // CarNameAndNum.text = decodedData.
////
////
////
////
////
////            } catch {
////                print("Error decoding JSON: \(error)")
////            }
//
//
//
//
//
//
//        }
//
//        // Start the data task
//        task.resume()
//    }
//
//

    var pointsAnnotations: [MKPointAnnotation] = []

    func fetchData() {
        // API endpoint URL
        let id = Request.shared.driver?.id
        var str  = String()
        str = "\(id ?? 0)"
        let url = URL(string: Config.Backend + "driver/" + str)!

        // Create URLRequest with the URL
        var request = URLRequest(url: url)
        
        // Add Bearer token to the request header
        let token = UserDefaultsConfig.jwtToken
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        
        // Create URLSession
        let session = URLSession.shared
        
        // Create data task to fetch data from the API
        let task = session.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // Check if there's a response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No HTTP response")
                return
            }
            
            // Check the status code
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP Error: \(httpResponse.statusCode)")
                return
            }
            
            // Check if data is received
            guard let data = data else {
                print("No data received")
                return
            }

            do {
                // Parse JSON data into a dictionary
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let data = jsonObject["data"] as? [String: Any],
                   let driver = data["driver"] as? [String: Any],
                   let assignedVehicle = driver["assignedVehicle"] as? [String: Any],
                   let agency = driver["agency"] as? [String: Any],
                    let driverMedia = driver["driverMedia"] as? [[String: Any]] {
                
                    print("No data received",data)

                    // Extract car details
                    let licensePlateNumber = assignedVehicle["license_plate_number"] as? String ?? "N/A"
                    let make = assignedVehicle["make"] as? String ?? "N/A"
                    let model = assignedVehicle["model"] as? String ?? "N/A"
                    let color = assignedVehicle["color"] as? String ?? "N/A"
                    let vehicleType = assignedVehicle["vehicle_type"] as? String ?? "N/A"
                    let notes = assignedVehicle["notes"] as? String ?? "N/A"
                    let agencyName = agency["agency_name"] as? String ?? "N/A"
                    let agencyyear = agency["registration_year"] as? String ?? "N/A"
                    let agencaddress = agency["address"] as? String ?? "N/A"
                    let fullname = agency["fullname"] as? String ?? "N/A"
                    let phone = agency["phone"] as? String ?? "N/A"
                    let email = agency["email"] as? String ?? "N/A"
                    let logo_url = agency["logo_url"] as? String ?? "N/A"

                    // Print car details
                    print("License Plate Number: \(licensePlateNumber)")
                    print("Make: \(make)")
                    print("Model: \(model)")
                    print("Color: \(color)")
                    print("Vehicle Type: \(vehicleType)")
                    print("Notes: \(notes)")
                    print("Agency Name: \(agencyName)")
                    print("Agency add: \(agencyName)")

                    // Update UI on the main thread
                    DispatchQueue.main.async {
                        self.CarNameAndNum.text = make + " " + color + " " + model + " " + vehicleType + " " + licensePlateNumber
                        self.AGencyName.text = agencyName
                        
                        self.AgencyNameText.text = agencyName
                        self.Agency_Year.text = agencyName + " (" + agencyyear  + ")"
                        self.Agency_Address.text = agencaddress
                        self.Full_name.text = fullname
                        self.emai_text.text = email
                        self.phone_number.text = phone
                        
                        
                        let profileMediaUrl = driverMedia.first { $0["mediaType"] as? String == "profile" }?["url"] as? String ?? ""
                                        let fullProfileUrl = Config.Backend + logo_url
                                        
                        let fullProfileUrl1 = Config.Backend + profileMediaUrl

                        self.Agency_image.layer.cornerRadius = 50
                        self.Agency_image.layer.masksToBounds = true
                        self.imgDriver.layer.cornerRadius = 40
                        self.imgDriver.layer.masksToBounds = true
                        if let encodedProfileUrl = fullProfileUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                                                if let mediaUrl = URL(string: encodedProfileUrl) {
                                                    self.Agency_image.kf.setImage(with: mediaUrl, placeholder: UIImage(named: "profile"))
                                                } else {
                                                    print("Invalid mediaUrl: \(encodedProfileUrl)")
                                                }
                                            }
                        if let encodedProfileUrl = fullProfileUrl1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                                                if let mediaUrl = URL(string: encodedProfileUrl) {
                                                    self.imgDriver.kf.setImage(with: mediaUrl, placeholder: UIImage(named: "Nobody"))
                                                } else {
                                                    print("Invalid mediaUrl: \(encodedProfileUrl)")
                                                }
                                            }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Start the data task
        task.resume()
    }

    private func refreshScreen(travel: Request = Request.shared, driverLocation: CLLocationCoordinate2D?) {
        if let cost = Request.shared.costAfterVAT {
            self.labelCost.text = MyLocale.formattedCurrency(amount: cost, currency: Request.shared.currency!)
        }
        if let driverImage = travel.driver?.media?.address {
            let processor = DownsamplingImageProcessor(size: imgDriver.intrinsicContentSize) |> RoundCornerImageProcessor(cornerRadius: imgDriver.intrinsicContentSize.width / 2)
            let url = URL(string: Config.Backend + driverImage.replacingOccurrences(of: " ", with: "%20"))
            imgDriver.kf.setImage(with: url, placeholder: UIImage(named: "Nobody"), options: [
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
        
        
        switch travel.status! {
        case .RiderCanceled, .DriverCanceled:
            let alert = UIAlertController(title: NSLocalizedString("Message", comment: ""), message: NSLocalizedString("Service Has Been Canceled.", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Alright!", comment: ""), style: .default) { action in
                _ = self.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
            if (travel.status == .DriverCanceled ){
                playNotificationSound(soundname: "ride_cancel")
            }
            break
            
        case .DriverAccepted:
            pickupMarker.coordinate = travel.points[0]
            map.addAnnotation(pickupMarker)
            if let _location = driverLocation {
                driverMarker.coordinate = _location
                map.addAnnotation(driverMarker)
                map.showAnnotations([pickupMarker, driverMarker], animated: true)
                showRoute(from: pickupMarker.coordinate, to: driverMarker.coordinate) // Show route between pickup and driver
            } else {
                let region = MKCoordinateRegion(center: travel.points[0], latitudinalMeters: 1000, longitudinalMeters: 1000)
                map.setRegion(region, animated: true)
            }
            playNotificationSound(soundname: "notification")
            break
            
        case .Arrived:
            SPAlert.present(title: "Driver has arrived", preset: .flag)
            playNotificationSound(soundname: "driver_arrived")
            // Optionally show route when the driver arrives
            if let firstDestination = travel.points.first {
                showRoute(from: driverMarker.coordinate, to: firstDestination)
            }
            break
            
        case .Started:
            buttonCall.isHidden = true
            buttonCallSlide.isHidden = true
            buttonMessage.isHidden = true
            buttonCancel.isHidden = true
            buttonCancelSlide.isHidden = true

            map.removeAnnotation(pickupMarker)
            for (index, point) in travel.points.enumerated() {
                if index == 0 {
                    continue;
                }
                let p = MKPointAnnotation()
                p.coordinate = point
                destinationMarkers.append(p)
                map.addAnnotation(p)
            }
            if driverLocation != nil || destinationMarkers.count > 1 {
                if(driverLocation != nil) {
                    driverMarker.coordinate = driverLocation!
                    map.addAnnotation(driverMarker)
                    destinationMarkers.append(driverMarker)
                    map.showAnnotations(destinationMarkers, animated: true)
                    destinationMarkers.removeLast()
                } else {
                    map.showAnnotations(destinationMarkers, animated: true)
                }
            } else {
                let region = MKCoordinateRegion(center: travel.points[1], latitudinalMeters: 1000, longitudinalMeters: 1000)
                map.setRegion(region, animated: true)
            }
            if let pickupLocation = travel.points.first, let dropoffLocation = travel.points.last {
                //showRoute(from: pickupLocation, to: dropoffLocation) // Show route between pickup and drop-off location
                
                let waypoints = travel.points
                drawRoute(waypoints: waypoints)
                
                
            }
            playNotificationSound(soundname: "ride_start")
            break
            
        case .WaitingForPostPay, .DriverMarkedPaymentNotReceived:
            if travel.service?.paymentMethod == .OnlyCash {
                let alert = UIAlertController(title: NSLocalizedString("Payment", comment: ""), message: NSLocalizedString("Service Has Been finished and payment is waiting to be settled.", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Alright!", comment: ""), style: .default) { action in
                    self.requestRefresh()
                })
            }
            else {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletNewViewController") as? WalletNewViewController {
                    vc.amount = Request.shared.costAfterVAT
                    vc.currency = Request.shared.currency
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            break
            
        case .WaitingForReview:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "finishedViewController")
            self.navigationController?.pushViewController(controller, animated: false)
            break
            
        case .Finished:
            SPAlert.present(title: NSLocalizedString("Done!", comment: ""), preset: .done)
            self.navigationController?.popViewController(animated: true)
            
        default:
            let alert = UIAlertController(title: "Error", message: "Unknown status: \(travel.status!.rawValue)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Allright!", style: .default) { action in
                _ = self.navigationController?.popViewController(animated: true)
            })
            self.present(alert, animated: true)
        }
    }

    
    
    
    
//    private func showRoute(from sourceCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D) {
//        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
//        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
//
//        let directionRequest = MKDirections.Request()
//        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
//        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
//        directionRequest.transportType = .automobile
//
//        let directions = MKDirections(request: directionRequest)
//        directions.calculate { [unowned self] response, error in
//            guard let response = response, error == nil else {
//                print("Error calculating directions: \(String(describing: error))")
//                return
//            }
//
//            if let routeOverlay = self.routeOverlay {
//                self.map.removeOverlay(routeOverlay)
//            }
//
//            let route = response.routes[0]
//            self.routeOverlay = route.polyline
//            self.map.addOverlay(self.routeOverlay!, level: .aboveRoads)
//
//            let rect = route.polyline.boundingMapRect
//            self.map.setRegion(MKCoordinateRegion(rect), animated: true)
//        }
//    }
    
    
    
    
    private func showRoute(from sourceCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { [unowned self] response, error in
            guard let response = response, error == nil else {
                print("Error calculating directions: \(String(describing: error))")
                return
            }
            
            if let routeOverlay = self.routeOverlay {
                self.map.removeOverlay(routeOverlay)
            }
            
            let route = response.routes[0]
            self.routeOverlay = route.polyline
            self.map.addOverlay(self.routeOverlay!, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.map.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }

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

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.black
            polylineRenderer.lineWidth = 2.0
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    
    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if overlay is MKPolyline {
//            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
//            polylineRenderer.strokeColor = UIColor.blue
//            polylineRenderer.lineWidth = 4.0
//            return polylineRenderer
//        }
//        return MKOverlayRenderer(overlay: overlay)
//    }
//
    @IBAction func onCancelTapped(_ sender: UIButton) {
        Cancel().execute() { result in
            switch result {
            case .success(_):
                Request.shared.status = .RiderCanceled
                self.refreshScreen(driverLocation: nil)
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
    @IBAction func onWalletTapped(_ sender: UIButton) {
        buttonPay.isHidden = true
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Wallet") as? WalletViewController {
            vc.amount = Request.shared.costAfterVAT
            vc.currency = Request.shared.currency
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    @objc func onServiceStarted(_ notification: Notification) {
        Request.shared = notification.object as! Request
        let location = driverMarker.coordinate.latitude != 0 ? driverMarker.coordinate : nil
        refreshScreen(driverLocation: location)
    }
    
    @objc func onArrived(_ notification: Notification) {
        Request.shared = notification.object as! Request
        refreshScreen(driverLocation: nil)
    }
    
    @objc func onServiceCanceled(_ notification: Notification) {
        Request.shared.status = .DriverCanceled
        refreshScreen(driverLocation: nil)
    }
    
    @objc func onServiceFinished(_ notification: Notification) {
        
        let obj = notification.object as! [Any]
        playNotificationSound(soundname: "ride_finished")
        Request.shared.status = (obj[0] as! Bool) == true ? Request.Status.WaitingForReview : Request.Status.WaitingForPostPay
        refreshScreen(driverLocation: nil)
        
    }
    
    @objc func onTravelInfoReceived(_ notification: Notification) {
        refreshScreen(driverLocation: (notification.object as! CLLocationCoordinate2D))
    }
    
    @IBAction func onSelectCouponClicked(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CouponsCollectionViewController") as? CouponsCollectionViewController
        {
            
            vc.selectMode = true
            vc.delegate = self
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func didSelectedCoupon(_ coupon: Coupon) {
//        ApplyCoupon(code: coupon.code!).execute() { result in
//            switch result {
//            case .success(_):
//                SPAlert.present(title: "Coupon Applied", preset: .done)
//                self.requestRefresh()
//                
//            case .failure(let error):
//                error.showAlert()
//            }
//        }
        
        
        CalculateFareAfterCoupon(code: coupon.code!, locations: []).execute() { result in
            switch result {
            case .success(_):
                SPAlert.present(title: "Coupon Applied", preset: .done)
                self.requestRefresh()
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
    enum MarkerType: String {
        case pickup = "pickup"
        case dropoff = "dropOff"
        case driver = "driver"
        case Stop = "stop"
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? MKPointAnnotation else { return nil }
//        let identifier = annotation == pickupMarker ? MarkerType.pickup : (annotation == driverMarker ? MarkerType.driver : MarkerType.dropoff)
//        var view: MKMarkerAnnotationView
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier.rawValue) as? MKMarkerAnnotationView {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier.rawValue)
////            switch(identifier) {
////            case .pickup:
////                view.glyphImage = UIImage(named: "annotation_glyph_home")
////               // view.markerTintColor = UIColor(hex: 0x009688)
////                break;
////
////            case .dropoff:
////              //  view.markerTintColor = UIColor(hex: 0xFFA000)
////                view.glyphImage = UIImage(named: "annotation_glyph_home")
////
////                break;
////
////            default:
////                view.image = UIImage(named: "marker_taxi")
////            }
//            view.backgroundColor = .clear
//            view.glyphTintColor = .clear
//            view.markerTintColor = .clear
//
//            switch identifier {
//            case .pickup:
//                view.image = UIImage(named: "marker_p")
//            case .dropoff:
//                view.image = UIImage(named: "marker_d")
//            case .Stop:
//                view.image = createNumberedMarkerImage(for: annotation)
//            default:
//                view.image = UIImage(named: "marker_taxi 1")
//            }
//        }
//        return view
//    }
    
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKPointAnnotation else { return nil }
        print(annotation.title ?? "")

        var identifier: MarkerType

        if Request.shared.points.count > 2 {
            if Request.shared.points.first == annotation.coordinate {
                identifier = .pickup
            } else if Request.shared.points.last == annotation.coordinate {
                identifier = .dropoff
            } else if Request.shared.points.contains(annotation.coordinate) {
                identifier = .Stop
            } else {
                identifier = .driver
            }
        } else {
            if Request.shared.points.first == annotation.coordinate {
                identifier = .pickup
            } else if Request.shared.points.last == annotation.coordinate {
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
        guard let index = Request.shared.points.firstIndex(of: annotation.coordinate) else { return nil }
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

    @IBAction func onCallTouched(_ sender: UIButton) {
        if let call = Request.shared.driver?.mobileNumber, let url = URL(string: "tel://\(call)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func enableConfirmationClicked(_ sender: UIBarButtonItem) {
        EnableVerification().execute() { result in
            switch result {
            case .success(let response):
                let message = UIAlertController(title: NSLocalizedString("Success", comment: ""), message: "Confirmation code service is enabled. Driver will need to enter \(response) to finish service.", preferredStyle: .alert)
                message.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
                self.present(message, animated: true)
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
}
extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
