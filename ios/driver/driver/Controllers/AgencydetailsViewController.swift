import UIKit
import Foundation
import Combine
import AVFoundation

class AgencydetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var agencyname: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var agdet: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load from UserDefaults
        fullNameLabel.text = UserDefaults.standard.string(forKey: "fullname") ?? ""
//        let lastname  = UserDefaults.standard.string(forKey: "lastName") ?? ""
//        fullNameLabel.text = "\(firstname) \(lastname)"
        
        phoneNumberLabel.text = UserDefaults.standard.string(forKey: "phone") ?? "N/A"
        emailLabel.text = UserDefaults.standard.string(forKey: "email") ?? "N/A"
        agencyname.text = UserDefaults.standard.string(forKey: "agencyName") ?? "N/A"
        agdet.text = UserDefaults.standard.string(forKey: "agencyName") ?? "N/A"
        location.text = UserDefaults.standard.string(forKey: "agencyAddress") ?? "N/A"

        if let logoPath = UserDefaults.standard.string(forKey: "logo_url") {
            let fullLogoUrl = Config.Backend + logoPath
            if let encodedUrl = fullLogoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let imageUrl = URL(string: encodedUrl) {
                self.loadImage(from: imageUrl)
            } else {
                print("⚠️ Invalid logo URL: \(logoPath)")
            }
        }

        // Then make API call to refresh data
        fetchData()
    }

    func fetchData() {
        guard let userData = UserDefaultsConfig.user,
              let user = try? Rider(from: userData),
              let id = user.id else {
            print("❌ Failed to load user from UserDefaults")
            return
        }

        let url = URL(string: Config.Backend + "driver/\(id)")!
        var request = URLRequest(url: url)
        let token = UserDefaultsConfig.jwtToken
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                print("❌ Invalid response or no data")
                return
            }

            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let responseData = jsonObject["data"] as? [String: Any],
                   let driver = responseData["driver"] as? [String: Any],
                   let assignedVehicle = driver["assignedVehicle"] as? [String: Any],
                   let agency = driver["agency"] as? [String: Any],
                   let driverMedia = driver["driverMedia"] as? [[String: Any]] {

                    // Extract and Save Agency Info
                    let agencyName = agency["agency_name"] as? String ?? ""
                    let agencyAddress = agency["address"] as? String ?? ""
                    let agencyEmail = agency["email"] as? String ?? ""
                    let agencyFullName = agency["fullname"] as? String ?? ""
                    
                    let agencyPhone = agency["phone"] as? String ?? ""
                    let agencyLogoUrl = agency["logo_url"] as? String ?? ""
                    let agencyRegisteredName = agency["registered_name"] as? String ?? ""
                    let agencyRegistrationYear = agency["registration_year"] as? Int ?? 0

                    UserDefaults.standard.set(agencyName, forKey: "agencyName")
                    UserDefaults.standard.set(agencyAddress, forKey: "agencyAddress")
                    UserDefaults.standard.set(agencyEmail, forKey: "email")
                    UserDefaults.standard.set(agencyFullName, forKey: "fullName")
                    UserDefaults.standard.set(agencyPhone, forKey: "phone")
                    UserDefaults.standard.set(agencyLogoUrl, forKey: "logo_url")
                    UserDefaults.standard.set(agencyRegisteredName, forKey: "registeredName")
                    UserDefaults.standard.set(agencyRegistrationYear, forKey: "registrationYear")

                    // Extract Car Details (if needed)
                    let licensePlateNumber = assignedVehicle["license_plate_number"] as? String ?? "N/A"
                    let make = assignedVehicle["make"] as? String ?? "N/A"
                    let model = assignedVehicle["model"] as? String ?? "N/A"
                    let color = assignedVehicle["color"] as? String ?? "N/A"
                    let vehicleType = assignedVehicle["vehicle_type"] as? String ?? "N/A"
                    let notes = assignedVehicle["notes"] as? String ?? "N/A"

                    print("✅ Saved agency & vehicle details:")
                    print("Agency: \(agencyName), \(agencyAddress)")
                    print("Vehicle: \(make) \(model) \(color) \(licensePlateNumber)")

                    DispatchQueue.main.async {
                        // Update UI immediately
                        self.fullNameLabel.text = agencyFullName
                        self.phoneNumberLabel.text = UserDefaults.standard.string(forKey: "phone") ?? ""
                        self.emailLabel.text = UserDefaults.standard.string(forKey: "email") ?? ""
                        self.agencyname.text = agencyName
                        self.location.text = agencyAddress

                        let fullLogoUrl = Config.Backend + agencyLogoUrl
                        if let encoded = fullLogoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                           let imageUrl = URL(string: encoded) {
                            self.loadImage(from: imageUrl)
                        }
                    }
                }
            } catch {
                print("❌ JSON Parsing error: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Image loading failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
