import UIKit

protocol SearchAgencyPopupDelegate: AnyObject {
    func didSelectAgency(_ agency: String, agencyId: Int)
}
class SearchAgencyPopupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let tableView = UITableView()
    let searchBar = UISearchBar()
    
    var allAgencies = [AgencyName.Agency]() // List of agencies with name and ID
        var filteredAgencies = [AgencyName.Agency]()  // Filtered search results
    weak var delegate: SearchAgencyPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 0.8, alpha: 0.9)
        
        setupSearchBar()
        setupTableView()
        
        // Simulate API call to fetch agencies
        fetchAgenciesFromAPI()
    }
    
    // Setup search bar
    func setupSearchBar() {
        searchBar.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: 50)
        searchBar.delegate = self
        searchBar.placeholder = "Search Agencies"
        view.addSubview(searchBar)
    }
    
    // Setup table view to show search results
    func setupTableView() {
        tableView.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.height - 100)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchAgencyCell")
        view.addSubview(tableView)
    }
    
    // Fetch agencies from API (Simulated here)
//    func fetchAgenciesFromAPI() {
//        // Simulate API data
//        self.allAgencies = ["Agency 1", "Agency 2", "Agency 3", "Agency 4", "Agency 5"]
//        self.filteredAgencies = allAgencies
//        tableView.reloadData()
//    }
    
    // Filter results when searching
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           if searchText.isEmpty {
               filteredAgencies = allAgencies
           } else {
               filteredAgencies = allAgencies.filter { $0.agency_name.lowercased().contains(searchText.lowercased()) }
           }
           tableView.reloadData()
       }
    
    // TableView Data Source methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAgencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "searchAgencyCell", for: indexPath)
           cell.textLabel?.text = filteredAgencies[indexPath.row].agency_name
           return cell
       }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAgency = filteredAgencies[indexPath.row]
        makePreferredAgency(agencyId: selectedAgency.id)
        delegate?.didSelectAgency(selectedAgency.agency_name, agencyId: selectedAgency.id)
        self.dismiss(animated: true, completion: nil)
    }
    func fetchAgenciesFromAPI() {
            Task {
                do {
                    let agencies = try await getAgencyList(token: UserDefaultsConfig.jwtToken ?? "")
                    self.allAgencies = agencies
                    self.filteredAgencies = self.allAgencies
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Failed to fetch agencies: \(error.localizedDescription)")
                }
            }
        }
    func getAgencyList(token: String) async throws -> [AgencyName.Agency] {
        let urlString = Config.Backend + "agency/names"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let agencyResponse = try JSONDecoder().decode(AgencyName.self, from: data)
        return agencyResponse.data.agencies
    }

    func postPreferredAgency(preferences: PreferenceAgencyRequest, token: String) async throws -> PrefDriverPostResult {
        let urlString = Config.Backend + "rider/make-agency/preference"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Encode the request body
        let jsonData = try JSONEncoder().encode(preferences)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let postResult = try JSONDecoder().decode(PrefDriverPostResult.self, from: data)
        return postResult
    }
    func makePreferredAgency(agencyId: Int) {
        
        let user = try! Rider(from: UserDefaultsConfig.user!)

        Task {
            do {
               
                let preferences = PreferenceAgencyRequest(
                    agency_preferences: [PreferenceAgencyRequest.AgencyPreference(agencyId: agencyId)],
                    riderId: user.id ?? 0
                )
                
                let token = UserDefaultsConfig.jwtToken ?? "" // Ensure this is fetched securely
                let result = try await postPreferredAgency(preferences: preferences, token: token)
                
                if result.success {
                    print("Success: \(result.message)")
                    // Update UI on success
                } else {
                    print("Failed: \(result.message)")
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }


    
}
import Foundation

struct AgencyName: Codable {
    let data: AgencyData
    let length: Int
    let success: Bool
    
    struct AgencyData: Codable {
        let agencies: [Agency]
    }

    struct Agency: Codable {
        let agency_name: String
        let id: Int
    }
}
struct PreferenceAgencyRequest: Codable {
    let agency_preferences: [AgencyPreference]
    let riderId: Int
    
    struct AgencyPreference: Codable {
        let agencyId: Int
    }
}

// Response model for the POST API
struct PrefDriverPostResult: Codable {
    let success: Bool
    let message: String
}
