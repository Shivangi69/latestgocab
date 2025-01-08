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
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TripHistoryCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of TripHistoryTableCell.")
        }

        let travel = travels[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        cell.pickupLabel.text = travel.addresses[0]
        if travel.addresses.count > 1 {
            cell.destinationLabel.text = travel.addresses.last
        }
        if let startTimestamp = travel.startTimestamp {
            cell.startTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(startTimestamp / 1000)))
        }
        if let finishTimestamp = travel.finishTimestamp {
            cell.finishTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(finishTimestamp / 1000)))
        }
        cell.Amountlbl.text = MyLocale.formattedCurrency(amount: travel.costAfterVAT ?? 0, currency: travel.currency!)
        cell.idLabel.text =  "#" +  (travel.id.map { String($0) } ?? "")
        cell.driverName.text = travel.rider?.firstName
        cell.AgencyName.text = travel.driver?.agency?.agency_name
        cell.carNumber.text = ""//travel.vehicle?.license_plate_number
        
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.unitStyle = .abbreviated
        distanceFormatter.units = .metric // Set units to metric

        let distanceInMeters = Double(travel.distanceReal ?? 0)
        let formattedDistance = distanceFormatter.string(fromDistance: distanceInMeters)

        //print("Formatted Distance: \(formattedDistance)")
        cell.cartype.text = ""//travel.service?.title
        cell.distance.text = "(" + formattedDistance + ")"
        cell.tripStatusvalue.text = travel.status!.rawValue.splitBefore(separator: { $0.isUppercase }).map { String($0) }.joined(separator: " ")

        let localeLanguage = Locale.current.languageCode ?? "en"
        let pointsQuery = travel.points.enumerated().map { (index, point) in
            return "markers=color:red|label:\(index + 1)|\(point.latitude),\(point.longitude)"
        }.joined(separator: "&")

        var mapUrl = "https://maps.googleapis.com/maps/api/staticmap?size=500x400&language=\(localeLanguage)&\(pointsQuery )&key=AIzaSyCW_G5rejKDXuhXYN8sITHhPRdX9_zbK5A"
        
        if let waypoints = travel.waypoints {
            
            let polylinePath = waypoints.map {"\($0.latitude),\($0.longitude)"}.joined(separator: "|")
            print(polylinePath)
            mapUrl += "&path=weight:10|color:0x000000|\(polylinePath)"

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
            }
            else {
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

        // Set delete action
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
