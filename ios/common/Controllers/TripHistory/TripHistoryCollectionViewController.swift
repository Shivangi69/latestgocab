//
//  TravelTableViewController.swift
//  Rider
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

import UIKit
import SPAlert
import Kingfisher
import MapKit
import GoogleMaps

class TripHistoryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    //MARK: Properties
    let cellIdentifier = "TripHistoryCollectionViewCell"
    
    var travels = [Request]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibCell = UINib(nibName: cellIdentifier, bundle: nil)
        collectionView?.register(nibCell, forCellWithReuseIdentifier: cellIdentifier)
        self.refreshList(self)
    }

    @IBAction func refreshList(_ sender: Any) {
        GetRequestHistory().execute() { result in
            switch result {
            case .success(let response):
                self.travels = response
                self.collectionView?.reloadData()
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kWhateverHeightYouWant = 255
        return CGSize(width: collectionView.bounds.size.width - 16, height: CGFloat(kWhateverHeightYouWant))
    }
    
    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            let complaint = UIAction(title: NSLocalizedString("Write Complaint", comment: ""), image: UIImage(systemName: "square.and.pencil")) { action in
                let title = NSLocalizedString("Complaint", comment: "")
                let message = NSLocalizedString("You can write a complaint on service provided and it will be reviewed As soon as possible.", comment: "")
                let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
                dialog.addTextField() { textField in
                    textField.placeholder = NSLocalizedString("Title...", comment: "")
                }
                dialog.addTextField() { textField in
                    textField.placeholder = NSLocalizedString("Content...", comment: "")
                }
                dialog.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { action in
                    WriteComplaint(requestId: self.travels[indexPath.row].id!, subject: dialog.textFields![0].text!, content: dialog.textFields![1].text!).execute() { result in
                        switch result {
                        case .success(_):
                            SPAlert.present(title: NSLocalizedString("Complaint Sent", comment: ""), preset: .done)
                            
                        case .failure(let error):
                            error.showAlert()
                        }
                    }
                })
                dialog.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
                self.present(dialog, animated: true)
            }

            // Here we specify the "destructive" attribute to show that it’s destructive in nature
            let hide = UIAction(title: NSLocalizedString("Hide Item", comment: ""), image: UIImage(systemName: "eye.slash"), attributes: .destructive) { action in
                HideHistoryItem(requestId: self.travels[indexPath.row].id!).execute() { result in
                    switch result {
                    case .success(_):
                        self.refreshList(self)
                        
                    case .failure(let error):
                        error.showAlert()
                    }
                }
            }
            var buttons = [complaint]
            if SocketNetworkDispatcher.instance.userType == .Rider {
                buttons.append(hide)
            }
            // The "title" will show up as an action for opening this menu
            //let edit = UIMenu(title: "Write Complaint", children: [complaint])

            // Create our menu with both the edit menu and the share action
            return UIMenu(title: NSLocalizedString("Options", comment: ""), children: buttons)
        })
    }
    
    override func numberOfSections(in tableView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return travels.count
    }
    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TripHistoryCollectionViewCell  else {
//            fatalError("The dequeued cell is not an instance of TripHistoryTableCell.")
//        }
//        let travel = travels[indexPath.row]
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .medium
//        cell.pickupLabel.text = travel.addresses[0]
//        if travel.addresses.count > 1 {
//            cell.destinationLabel.text = travel.addresses.last
//        }
//        if let startTimestamp = travel.startTimestamp {
//            cell.startTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(startTimestamp / 1000)))
//        }
//        if let finishTimestamp = travel.finishTimestamp {
//            cell.finishTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(finishTimestamp / 1000)))
//        }
//        cell.Amountlbl.text = MyLocale.formattedCurrency(amount: travel.costAfterVAT ?? 0, currency: travel.currency!)
//        cell.idLabel.text =  "#" +  (travel.id.map { String($0) } ?? "")
//        cell.driverName.text = travel.driver?.displayName
//        cell.AgencyName.text = travel.driver?.agency?.agency_name
//        cell.distance.text = "(" + (travel.distanceReal.map { String($0) } ?? "") + ")"
//        cell.tripStatusvalue.text = travel.status!.rawValue.splitBefore(separator: { $0.isUppercase }).map{String($0)}.joined(separator: " ")
//
//
//        let localeLanguage = Locale.current.languageCode ?? "en"
//        var pointsQuery = travel.points.enumerated().map { (index, point) in
//            return "markers=color:red|label:\(index + 1)|\(point.latitude),\(point.longitude)"
//        }.joined(separator: "&")
//
//        var mapUrl = "https://maps.googleapis.com/maps/api/staticmap?size=500x400&language=\(localeLanguage)&\(pointsQuery)&key=\("AIzaSyCW_G5rejKDXuhXYN8sITHhPRdX9_zbK5A")"
//
//        let polylinePath = travel.waypoints.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
//        mapUrl += "&path=weight:10|color:0x000000|\(polylinePath)"
//
//        if let log = travel.log, !log.isEmpty {
//            mapUrl += "&path=weight:3|color:orange|enc:\(log)"
//        }
//
//        //travel.imageUrl = mapUrl
//        cell.tripImage.kf.setImage(with: URL(string: mapUrl), placeholder: UIImage(named: "placeholder_image"))
////
//        let processor = DownsamplingImageProcessor(size: cell.tripImage.intrinsicContentSize) |> RoundCornerImageProcessor(cornerRadius: cell.tripImage.intrinsicContentSize.width / 2)
//
////        cell.tripImage.kf.setImage(with: URL(string: mapUrl), placeholder: UIImage(named: "Nobody"), options: [
////            .processor(processor),
////            .scaleFactor(UIScreen.main.scale),
////            .transition(.fade(0.5)),
////            .cacheOriginalImage
////        ], completionHandler: { result in
////            switch result {
////            case .success(let value):
////                //print("Task done for: \(value.source.url?.absoluteString ?? "")")
////            case .failure(let error):
////                //print("Job failed: \(error.localizedDescription)")
////            }
////        })
////
//        let driverMedia = travel.driver?.driverMedia?.first(where: { $0.mediaType == "profile" })?.url ?? ""
//let str = Config.Backend + driverMedia
//        if let mediaUrl = URL(string: str) {
//            //print(mediaUrl)
//
//            cell.driverImage.kf.setImage(with: mediaUrl, placeholder: UIImage(named: "profile"))
//        }
//       // cell.driverImage.kf.setImage(with: URL(string: travel.driver?.driverMedia?.url ?? ""), placeholder: UIImage(named: "placeholder_image"))
//
//        //print(mapUrl)
//
//
//        return cell
//    }
    
    func showFeedbackPopup() {
         let feedbackVC = FeedbackPopupViewController()
         feedbackVC.modalPresentationStyle = .overCurrentContext
         feedbackVC.modalTransitionStyle = .crossDissolve
         present(feedbackVC, animated: true, completion: nil)
     }
    
    func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double, completion: @escaping (String?) -> Void) {
        let locc = CLLocationCoordinate2D(latitude: pdblLatitude, longitude: pdblLongitude)

        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(locc) { response, error in
            var addressString: String?

            if let error = error {
                print("reverse geocode failed: \(error.localizedDescription)")
                completion(nil)
            }
            else {
                if let places = response?.results(), let place = places.first {
                    if let lines = place.lines {
                        addressString = lines.first
                    } else {
                        print("GEOCODE: nil in lines")
                    }
                } else {
                    print("GEOCODE: nil in places")
                }
                completion(addressString)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TripHistoryCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of TripHistoryTableCell.")
        }

        let travel = travels[indexPath.row]
//      let waypoints = travels.waypoints

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        cell.pickupLabel.text = travel.addresses[0]
        
        if let startTimestamp = travel.startTimestamp {
            cell.startTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(startTimestamp / 1000)))
        }
        if let finishTimestamp = travel.finishTimestamp {
            cell.finishTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(finishTimestamp / 1000)))
        }
        cell.Amountlbl.text = MyLocale.formattedCurrency(amount: travel.costAfterVAT ?? 0, currency: travel.currency!)
        cell.idLabel.text =  "#" +  (travel.id.map { String($0) } ?? "")
        cell.driverName.text = travel.driver?.displayName
        cell.AgencyName.text = travel.driver?.agency?.agency_name
        cell.carNumber.text = travel.vehicle?.license_plate_number
        
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.unitStyle = .abbreviated
        distanceFormatter.units = .metric
        // Set units to metric

        let distanceInMeters = Double(travel.distanceReal ?? 0)
        let formattedDistance = distanceFormatter.string(fromDistance: distanceInMeters)
        //print("Formatted Distance: \(formattedDistance)")
        cell.cartype.text = travel.service?.title
        cell.distance.text = "(" + formattedDistance + ")"
        
        
        //       Assuming cell.tripStatusButton is your UIButton
        //       cell.tripStatusvalue.setTitle(travel.status!.rawValue.splitBefore(separator: {  $0.isUppercase }).map { String($0) }.joined(separator: " "), for: .normal)
        
        //        cell.tripStatusvalue = { [weak self] in
        //        Create the button that needs to be returned
        //        let button = UIButton()
        //
        //        Your code for presenting the feedback view controller
        //        let feedbackVC = FeedbackPopupViewController()
        //        feedbackVC.modalPresentationStyle = .overCurrentContext
        //        feedbackVC.modalTransitionStyle = .crossDissolve
        //        self?.present(feedbackVC, animated: true, completion: nil)
        //
        //            return button
        //        }
        
        
//        if travel.status?.rawValue ?? "" == "Finished" {
//            cell.tripStatusvalue.setTitleColor(UIColor.green, for: .normal)
//         }
//        
//        else {
//              cell.tripStatusvalue.setTitleColor(UIColor.green, for: .normal)
//           }
//                
        
        
        cell.tripStatusLbl.text = travel.status!.rawValue.splitBefore(separator: { $0.isUppercase }).map { String($0) }.joined(separator: " ")

        if travel.status?.rawValue ?? "" == "Finished" { // Assuming `.finish` is an enum case
            cell.tripStatusLbl.textColor = UIColor.green // Set to green for finished status
        }
        
        else if travel.status?.rawValue ?? "" == "PendingReview" { // Assuming `.finish` is an enum case
            cell.tripStatusLbl.textColor = UIColor.red
            cell.tripStatusLbl.isUserInteractionEnabled = true // Enable interaction
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
            cell.tripStatusLbl.addGestureRecognizer(tapGesture)
            
        }
        
        else {
            cell.tripStatusLbl.textColor = UIColor.red // Set to red for all other statuses
        }
        
        
        let localeLanguage = Locale.current.languageCode ?? "en"
        let pointsQuery = travel.points.enumerated().map { (index, point) in
            return "markers=color:red|label:\(index + 1)|\(point.latitude),\(point.longitude)"
        }.joined(separator: "&")

        var mapUrl = "https://maps.googleapis.com/maps/api/staticmap?size=500x400&language=\(localeLanguage)&\(pointsQuery)&key=AIzaSyCW_G5rejKDXuhXYN8sITHhPRdX9_zbK5A"

        if let waypoints = travel.waypoints {
            let polylinePath = waypoints.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
            print(polylinePath)
            mapUrl += "&path=weight:10|color:0x000000|\(polylinePath)"

            if travel.waypoints?.count ?? 0 > 1 {
                getAddressFromLatLon(pdblLatitude:travel.waypoints?.last?.latitude ?? 0.0 , withLongitude: travel.waypoints?.last?.longitude  ?? 0.0) { address in
                    if let address = address {
                        print("Address: \(address)")
                        // Update your UI or perform other actions with the address
                        cell.destinationLabel.text = address
                    }
                    else {
                        print("Failed to get address")
                    }
                }
            }
            
            else {
                cell.destinationLabel.text = travel.addresses[0]
            }
        }
        else {
            print("No waypoints available")
        }

//        let polylinePath = travel.waypoints.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")

        if let log = travel.log, !log.isEmpty {
            mapUrl += "&path=weight:3|color:orange|enc:\(log)"
        }

        if let encodedMapUrl = mapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            //print("Encoded Combined URL: \(encodedMapUrl)")
            if let mediaUrl = URL(string: encodedMapUrl) {
                //print("mediaUrl: \(mediaUrl)")
                cell.tripImage.kf.setImage(with: mediaUrl, placeholder: UIImage(named: "profile"))
            } else {
                //print("Invalid mediaUrl: \(encodedMapUrl)")
            }
        }

        let processor = DownsamplingImageProcessor(size: cell.tripImage.intrinsicContentSize) |> RoundCornerImageProcessor(cornerRadius: cell.tripImage.intrinsicContentSize.width / 2)

        let driverMedia = travel.driver?.driverMedia?.first(where: { $0.mediaType == "profile" })?.url ?? ""
        let str = Config.Backend + driverMedia

//        //print("Config.Backend: \(Config.Backend)")
//        //print("driverMedia: \(driverMedia)")
//        //print("Combined URL: \(str)")

        cell.driverImage.layer.cornerRadius = 25
        cell.driverImage.layer.masksToBounds = true

        if let encodedDriverMedia = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            //print("Encoded Combined URL: \(encodedDriverMedia)")
            if let mediaUrl = URL(string: encodedDriverMedia) {
               // //print("mediaUrl: \(mediaUrl)")
                cell.driverImage.kf.setImage(with: mediaUrl, placeholder: UIImage(named: "profile"))
            } else {
                ////print("Invalid mediaUrl: \(encodedDriverMedia)")
            }
        }
        cell.complainAction = {
            // Handle complain action here, e.g., show alert, initiate complaint process
            let title = NSLocalizedString("Complaint", comment: "")
            let message = NSLocalizedString("You can write a complaint on service provided and it will be reviewed As soon as possible.", comment: "")
            let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
            dialog.addTextField() { textField in
                textField.placeholder = NSLocalizedString("Title...", comment: "")
            }
            dialog.addTextField() { textField in
                textField.placeholder = NSLocalizedString("Content...", comment: "")
            }
            dialog.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { action in
                // Handle complaint submission
                WriteComplaint(requestId: travel.id!, subject: dialog.textFields![0].text!, content: dialog.textFields![1].text!).execute() { result in
                    switch result {
                    case .success(_):
                        SPAlert.present(title: NSLocalizedString("Complaint Sent", comment: ""), preset: .done)
                        
                    case .failure(let error):
                        error.showAlert()
                    }
                }
            })
            dialog.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
            self.present(dialog, animated: true)
        }
        cell.deleteAction = {
            // Handle delete action here, e.g., show confirmation, delete item
            HideHistoryItem(requestId: travel.id!).execute() { result in
                switch result {
                case .success(_):
                    self.refreshList(self)
                    
                case .failure(let error):
                    error.showAlert()
                }
            }
        }
        return cell
    }
   
    
  @objc func labelTapped() {
        // Create a dimmed background view
        let dimmedBackground = UIView(frame: UIScreen.main.bounds)
        dimmedBackground.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmedBackground.tag = 100     // To identify and remove it later if needed
        UIApplication.shared.keyWindow?.addSubview(dimmedBackground)
        
        // Create the custom modal view
        let modalView = UIView(frame: CGRect(x: 20, y: UIScreen.main.bounds.height / 2 - 150, width: UIScreen.main.bounds.width - 40, height: 250))
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = 12
        modalView.clipsToBounds = true
        dimmedBackground.addSubview(modalView)
        
        // Title Label
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 10, width: modalView.frame.width, height: 30))
        titleLabel.text = "Your Feedback Matters!"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        modalView.addSubview(titleLabel)
        
        // Text Field for review input
        let reviewTextField = UITextField(frame: CGRect(x: 10, y: 50, width: modalView.frame.width - 20, height: 40))
        reviewTextField.placeholder = "Write your review here..."
        reviewTextField.borderStyle = .roundedRect
        reviewTextField.font = UIFont.systemFont(ofSize: 14)
        modalView.addSubview(reviewTextField)
        
        // Character count label
        let charCountLabel = UILabel(frame: CGRect(x: modalView.frame.width - 60, y: 95, width: 50, height: 20))
        charCountLabel.text = "0/250"
        charCountLabel.font = UIFont.systemFont(ofSize: 12)
        charCountLabel.textAlignment = .right
        charCountLabel.textColor = .gray
        modalView.addSubview(charCountLabel)
      
        // Add text field editing listener
        reviewTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        reviewTextField.tag = 101 // To track the text field for updating the char count dynamically

        // Adjust spacing: Move the ratingLabel further down
        let verticalSpacing: CGFloat = 20 // Adjust this value to increase or decrease spacing

      
      // Rating label
      let ratingLabel = UILabel(frame: CGRect(x: 10, y: charCountLabel.frame.maxY + verticalSpacing, width: 50, height: 30))
      ratingLabel.text = "Rate:"
      ratingLabel.font = UIFont.systemFont(ofSize: 16)
      modalView.addSubview(ratingLabel)

      // Rating stars
      let starsStackView = UIStackView(frame: CGRect(x: 60, y: ratingLabel.frame.origin.y, width: modalView.frame.width - 70, height: 30))
      starsStackView.axis = .horizontal
      starsStackView.distribution = .equalSpacing
      starsStackView.alignment = .center
      starsStackView.spacing = 8
      for i in 0..<5 {
          let starButton = UIButton(type: .system)
          starButton.setImage(UIImage(systemName: "star"), for: .normal)
          starButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
          starButton.tintColor = .systemYellow
          starButton.tag = i + 1 // Set tag for identifying the selected star
          starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
          starsStackView.addArrangedSubview(starButton)
      }
      modalView.addSubview(starsStackView)

        // Cancel Button
        let cancelButton = UIButton(frame: CGRect(x: 10, y: modalView.frame.height - 50, width: modalView.frame.width / 2 - 15, height: 40))
        cancelButton.setTitle("CANCEL", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(dismissCustomModal), for: .touchUpInside)
        modalView.addSubview(cancelButton)
        
        // OK Button
        let okButton = UIButton(frame: CGRect(x: modalView.frame.width / 2 + 5, y: modalView.frame.height - 50, width: modalView.frame.width / 2 - 15, height: 40))
        okButton.setTitle("OK", for: .normal)
        okButton.setTitleColor(.white, for: .normal)
        okButton.backgroundColor = .systemGreen
        okButton.layer.cornerRadius = 8
        okButton.addTarget(self, action: #selector(okTapped), for: .touchUpInside)
        modalView.addSubview(okButton)
    }

   
    // MARK: - Actions

    @objc func textFieldEditingChanged(_ textField: UITextField) {
        if let text = textField.text, let charCountLabel = UIApplication.shared.keyWindow?.viewWithTag(100)?.viewWithTag(101) as? UILabel {
            charCountLabel.text = "\(text.count)/250"
        }
    }

    @objc func starTapped(_ sender: UIButton) {
        // Highlight selected stars
        for tag in 1...5 {
            if let starButton = sender.superview?.viewWithTag(tag) as? UIButton {
                starButton.isSelected = tag <= sender.tag
            }
        }
    }

    @objc func dismissCustomModal() {
        if let dimmedBackground = UIApplication.shared.keyWindow?.viewWithTag(100) {
            dimmedBackground.removeFromSuperview()
        }
    }

    @objc func okTapped() {
        // Dismiss the modal and handle submission logic
        dismissCustomModal()
        print("Feedback submitted!")
    }



}

extension Character {
    var isUpperCase: Bool { return String(self) == String(self).uppercased() }
}

extension Sequence {
    func splitBefore(
        separator isSeparator: (Iterator.Element) throws -> Bool
    ) rethrows -> [AnySequence<Iterator.Element>] {
        var result: [AnySequence<Iterator.Element>] = []
        var subSequence: [Iterator.Element] = []

        var iterator = self.makeIterator()
        while let element = iterator.next() {
            if try isSeparator(element) {
                if !subSequence.isEmpty {
                    result.append(AnySequence(subSequence))
                }
                subSequence = [element]
            }
            else {
                subSequence.append(element)
            }
        }
        result.append(AnySequence(subSequence))
        return result
    }
}

class FeedbackPopupViewController: UIViewController {

    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Feedback Matters!"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.text = "Write your review here..."
        textView.textColor = .lightGray
        return textView
    }()
    
    private let starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("CANCEL", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    private let okButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("OK", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 16

        // Add Subviews
        [titleLabel, textView, starStackView, cancelButton, okButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Configure Star Ratings
        for _ in 1...5 {
            let starButton = UIButton()
            starButton.setImage(UIImage(systemName: "star"), for: .normal)
            starButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
            starButton.tintColor = .systemYellow
            starStackView.addArrangedSubview(starButton)
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
        }

        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 100),

            starStackView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            starStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            cancelButton.topAnchor.constraint(equalTo: starStackView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            okButton.topAnchor.constraint(equalTo: starStackView.bottomAnchor, constant: 16),
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            okButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])

        // Button Actions
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        okButton.addTarget(self, action: #selector(okTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func starTapped(_ sender: UIButton) {
        guard let stackView = sender.superview as? UIStackView else { return }
        for (index, button) in stackView.arrangedSubviews.enumerated() {
            guard let starButton = button as? UIButton else { continue }
            starButton.isSelected = index <= stackView.arrangedSubviews.firstIndex(of: sender)!
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func okTapped() {
        // Handle OK Action (e.g., send feedback)
        dismiss(animated: true, completion: nil)
    }
}
