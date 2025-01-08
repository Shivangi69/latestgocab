//
//  PreferredAgenciesViewController.swift
//  rider
//
//  Created by Admin on 25/09/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit

class PreferredAgenciesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedAgencies = [String]() // Holds the selected agencies
    var selectedAgenciesID = [Int]()
    let tableView = UITableView()
    let emptyStateLabel = UILabel()
    let addAgencyButton = UIButton()
    var rider: Rider!
    let selectedLabel = UILabel()
    let noOfselectedlabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Preferred Agencies"
       
        let user = try! Rider(from: UserDefaultsConfig.user!)
        let token = UserDefaultsConfig.jwtToken ?? ""
        
        getPreferredAgency(riderId: user.id ?? 0, token: token) { result in
            switch result {
            case .success(let agencies):
                for agency in agencies {
                    print("Agency Name: \(agency.agencyName), Status: \(agency.priority)")
                    self.selectedAgencies.append(agency.agencyName)
                    self.selectedAgenciesID.append(agency.agencyId)

                }
                DispatchQueue.main.async {
                               self.tableView.reloadData()
                               self.updateUI()
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
        
        setupEmptyState()
        setupTableView()
        setupAddAgencyButton()
        if selectedAgencies.isEmpty {
            setupSkiButton()
        }
//        else  {
//            setupDoneButton()
//        }
        
        setupDoneButton()
       
        updateUI()
       
    }
    let doneButton = UIButton()
    let Skipbutton = UIButton()
    let messageLabel = UILabel()

    func setupSkiButton() {
        // Configure the Skip button
        Skipbutton.frame = CGRect(
            x: 50,
            y: view.frame.height - 150, // Positioned higher than the label
            width: view.frame.width - 100,
            height: 50
        )
        
        let attributedString = NSAttributedString(string: " Skip ", attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
            
        ])
        Skipbutton.setAttributedTitle(attributedString, for: .normal)
        Skipbutton.setTitleColor(.black, for: .normal)
 
        view.addSubview(Skipbutton)
        messageLabel.frame = CGRect(
            x: 20,
            y: Skipbutton.frame.maxY + 20, // Positioned below the Skip button with some spacing
            width: view.frame.width - 40,
            height: 60
        )
        
        messageLabel.text = "Pick 3 preferred agencies. Drivers from your selected agencies will be contacted first in the defined order and then from the rest."
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 5
        messageLabel.lineBreakMode = .byWordWrapping
        view.addSubview(messageLabel)
    }
    
    func setupDoneButton() {
        doneButton.frame = CGRect(x: 50, y: view.frame.height - 80, width: view.frame.width - 100, height: 50)
        let attributedString = NSAttributedString(string: " Done ", attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])

        doneButton.setAttributedTitle(attributedString, for: .normal)
        doneButton.setTitleColor(UIColor(named: "ThemeBlue"), for: .normal)
        messageLabel.isHidden = true
//        doneButton.backgroundColor = UIColor(named: "ThemeBlue")
//        doneButton.layer.cornerRadius = 10
        doneButton.addTarget(self, action: #selector(reorderAgencies), for: .touchUpInside)
        view.addSubview(doneButton)
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
                        self.navigationController!.pushViewController(vc, animated: true)
                }
    }
    
    @objc func reorderAgencies() {
        // Construct the reordered list with indices
        var reorderedAgencies: [ReorderingRequest.AgencyPreference] = []
        for (index, agencyId) in selectedAgenciesID.enumerated() {
            reorderedAgencies.append(ReorderingRequest.AgencyPreference(agencyId: agencyId, priority: index + 1))
        }
        let user = try! Rider(from: UserDefaultsConfig.user!)
        let token = UserDefaultsConfig.jwtToken ?? ""
        
        // Prepare the request data
        let riderId = user.id ?? 0
        let reorderingRequest = ReorderingRequest(agency_preferences: reorderedAgencies, riderId: riderId)
        // Call the API
        reorderPreferredAgencies(reorderingRequest: reorderingRequest, token: token)
    }

    func reorderPreferredAgencies(reorderingRequest: ReorderingRequest, token: String) {
        let urlString = Config.Backend + "rider/reorder-agency/preference"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(reorderingRequest)
            request.httpBody = jsonData
        } catch {
            print("Error encoding request data: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }

            print("Reordering successful!")
        }
        
        task.resume()
    }

    
    func deletePrefAgency(agencyId: Int, riderId: Int, token: String) async throws -> DeletePrefResult {
        // Construct the URL
        let urlString =  Config.Backend  + "/rider/remove-agency/\(agencyId)/preference/\(riderId)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Set the Authorization header
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Perform the API request using async/await
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for a valid response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        // Parse the JSON response
        let deleteResult = try JSONDecoder().decode(DeletePrefResult.self, from: data)
        return deleteResult
    }
    
    func getPreferredAgency(riderId: Int, token: String, completion: @escaping (Result<[PreferredAgency], Error>) -> Void) {
        // Construct the URL
        let urlString = Config.Backend  + "rider/get-agency/preference/" + "\(riderId)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Set the Authorization header
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Perform the API request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check response and data
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                print("Invalid response or no data")
                return
            }
            
            
            
            do {
                let preferredAgencyResponse = try JSONDecoder().decode(PreferredAgencyResponse.self, from: data)
                completion(.success(preferredAgencyResponse.data.preferredAgencies))
                
                
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }
        
        task.resume()  // Start the task
    }
    
    // Setup empty state view
    
    func setupEmptyState() {
        emptyStateLabel.text = "You don't have any agencies selected :("
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.font = UIFont.boldSystemFont(ofSize: 25) // Set font size to 20 and bold

        emptyStateLabel.frame = CGRect(x: 0, y: 80, width: view.frame.width, height: 50)
        view.addSubview(emptyStateLabel)
        
        selectedLabel.text = "Selected Agencies"
        selectedLabel.textAlignment = .left
        selectedLabel.frame = CGRect(x: 10, y: 80, width: view.frame.width/2, height: 50)
        selectedLabel.isHidden = true
        view.addSubview(selectedLabel)
        
        noOfselectedlabel.text = String(selectedAgencies.count) +  "/3"
        noOfselectedlabel.textAlignment = .right
        noOfselectedlabel.frame = CGRect(x: view.frame.width/2 + 10, y: 80, width: view.frame.width/2, height: 50)
        noOfselectedlabel.isHidden = true
        view.addSubview(noOfselectedlabel)
    }
    
    
    
    // Setup table view to show selected agencies
    func setupTableView() {
        tableView.frame = CGRect(x: 10, y: 80, width: Int(view.frame.width-20), height: selectedAgencies.count * 60)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor(named: "ThemeGrey")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "agencyCell")
        self.tableView.isEditing = true
        view.addSubview(tableView)
    }
    
    // Setup Add Agency button
    func setupAddAgencyButton() {
        addAgencyButton.frame = CGRect(x: 50, y:tableView.frame.origin.y +  tableView.frame.size.height + 30, width: view.frame.width - 100, height: 50)
//        addAgencyButton.setTitle("Add Agency", for: .normal)
        let attributedString = NSAttributedString(string: " + Add ", attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])

        addAgencyButton.setAttributedTitle(attributedString, for: .normal)
        addAgencyButton.setTitleColor(UIColor(named: "ThemeBlue"), for: .normal)
      //  addAgencyButton.backgroundColor = .blue
        addAgencyButton.addTarget(self, action: #selector(openSearchablePopup), for: .touchUpInside)
        view.addSubview(addAgencyButton)
    }
    
    // Update UI based on selected agencies
    func updateUI() {
        if selectedAgencies.isEmpty {
            tableView.isHidden = true
            Skipbutton.isHidden = false
            messageLabel.isHidden = false
            doneButton.isHidden = true
            emptyStateLabel.isHidden = false
            tableView.frame.size.height =  CGFloat(selectedAgencies.count * 60)
            selectedLabel.isHidden = true
            noOfselectedlabel.isHidden = true

        }
        else {
            tableView.isHidden = false
            Skipbutton.isHidden = true
            messageLabel.isHidden = true
//            messageLabel.isHidden = true
            doneButton.isHidden = false
            emptyStateLabel.isHidden = true
            tableView.frame.size.height =  CGFloat(selectedAgencies.count * 60)
            selectedLabel.isHidden = true
            noOfselectedlabel.isHidden = true
            noOfselectedlabel.text = String(selectedAgencies.count) +  "/3"

        }
        addAgencyButton.frame.origin.y =  tableView.frame.origin.y +  tableView.frame.size.height + 30
        if (selectedAgencies.count >= 3)   {
            
            addAgencyButton.isHidden = true
            
        }
        else {
            addAgencyButton.isHidden = false
        }
        tableView.reloadData()
    }
    // Enable reordering of rows
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true // Allow all rows to be moved
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update your data source
        let movedAgency = selectedAgencies.remove(at: sourceIndexPath.row)
        selectedAgencies.insert(movedAgency, at: destinationIndexPath.row)

        let movedAgencyID = selectedAgenciesID.remove(at: sourceIndexPath.row)
        selectedAgenciesID.insert(movedAgencyID, at: destinationIndexPath.row)
    }

    // Open the searchable popup to add agencies
    @objc func openSearchablePopup() {
        let searchPopupVC = SearchAgencyPopupViewController()
        searchPopupVC.delegate = self
        self.present(searchPopupVC, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    // TableView Data Source methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedAgencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "agencyCell", for: indexPath)
        cell.textLabel?.text = selectedAgencies[indexPath.row]
        cell.backgroundColor = UIColor(named: "ThemeGrey")

        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("❌", for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        deleteButton.tag = indexPath.row // Set tag to identify the cell
        deleteButton.addTarget(self, action: #selector(deleteAgency(_:)), for: .touchUpInside)

        deleteButton.frame = CGRect(x: cell.bounds.width - 150, y: 0, width: 60, height: cell.bounds.height)
        deleteButton.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
        
        cell.contentView.addSubview(deleteButton)
        return cell
    }

    @objc func deleteAgency(_ sender: UIButton) {
        let agencyId = selectedAgenciesID[sender.tag]  // Replace with actual way to get agencyId
        
        let user = try! Rider(from: UserDefaultsConfig.user!)
        let token = UserDefaultsConfig.jwtToken ?? ""
        
        
        let riderId = user.id ?? 0
        Task {
            do {
                // Call the delete API
                let deleteResult = try await deletePrefAgency(agencyId: agencyId, riderId: riderId, token: token)
                
                // Check if the deletion was successful
                if deleteResult.success {
                    // Remove the deleted agency from the local list
                    DispatchQueue.main.async {
                        self.selectedAgencies.remove(at: sender.tag)
                        self.selectedAgenciesID.remove(at: sender.tag)
                        self.tableView.reloadData()
                        self.updateUI()
                    }
                    print("Agency deleted successfully: \(deleteResult.message)")
                } else {
                    print("Failed to delete agency: \(deleteResult.message)")
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        
    }
    
    @objc func showDeleteConfirmation(_ sender: UIButton) {
        let index = sender.tag
        let agency = selectedAgencies[index]

        let alert = UIAlertController(
            title: "Remove Agency",
            message: "Are you sure you want to remove \(agency) from the list?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { [weak self] _ in
            self?.deleteAgencyFromServer(at: index) // Call server-side delete
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if let viewController = self.parent {
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    func deleteAgencyFromServer(at index: Int) {
        let agencyId = selectedAgenciesID[index]
        let user = try! Rider(from: UserDefaultsConfig.user!)
        let token = UserDefaultsConfig.jwtToken ?? ""
        let riderId = user.id ?? 0

        Task {
            do {
                // Call the delete API
                let deleteResult = try await deletePrefAgency(agencyId: agencyId, riderId: riderId, token: token)

                if deleteResult.success {
                    DispatchQueue.main.async { [weak self] in
                        self?.deleteAgency(at: index) // Use the local delete function
                    }
                    print("Agency deleted successfully: \(deleteResult.message)")
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.showErrorAlert(message: deleteResult.message)
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(message: error.localizedDescription)
                }
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        if let viewController = self.parent {
            viewController.present(alert, animated: true, completion: nil)
        }
    }


    func deleteAgency(at index: Int) {
        selectedAgencies.remove(at: index)
        selectedAgenciesID.remove(at: index)
        tableView.reloadData()
        updateUI()
    }
    
    // Delete agency action
//    @objc func deleteAgency(_ sender: UIButton) {
//            let agencyId = selectedAgenciesID[sender.tag]  // Replace with actual way to get agencyId
//              
//            let user = try! Rider(from: UserDefaultsConfig.user!)
//            let token = UserDefaultsConfig.jwtToken ?? ""
//           
//            
//            let riderId = user.id ?? 0
//            Task {
//                do {
//                        // Call the delete API
//                    let deleteResult = try await deletePrefAgency(agencyId: agencyId, riderId: riderId, token: token)
//                        
//                        // Check if the deletion was successful
//                        if deleteResult.success {
//                            // Remove the deleted agency from the local list
//                            DispatchQueue.main.async {
//                                self.selectedAgencies.remove(at: sender.tag)
//                                self.selectedAgenciesID.remove(at: sender.tag)
//                                self.tableView.reloadData()
//                                self.updateUI()
//                            }
//                            
//                            print("Agency deleted successfully: \(deleteResult.message)")
//                            
//                        } else {
//                            
//                            print("Failed to delete agency: \(deleteResult.message)")
//                        }
//                    }
//                catch {
//                        print("Error: \(error.localizedDescription)")
//                    }
//                }
//      //  }
//    }
    
}
extension PreferredAgenciesViewController: SearchAgencyPopupDelegate {
    func didSelectAgency(_ agency: String, agencyId: Int) {
        // Add selected agency to the list if not already added and less than 3
        if !selectedAgencies.contains(agency) && selectedAgencies.count < 3 {
            selectedAgencies.append(agency)
            selectedAgenciesID.append(agencyId)

            updateUI()
        }
    }
}
struct DeletePrefResult: Codable {
    let success: Bool
    let message: String
}
struct ReorderingRequest: Codable {
    let agency_preferences: [AgencyPreference]
    let riderId: Int

    struct AgencyPreference: Codable {
        let agencyId: Int
        let priority: Int
    }
}
