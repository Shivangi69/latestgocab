//
//  ServicebottomSheetViewController.swift
//  rider
//
//  Created by Admin on 27/09/24.
//  Copyright © 2024 minimal. All rights reserved.
//


import UIKit

class ServicebottomSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    let cars: [(category: String, name: String, price: String, capacity: String, image: String)] = [
        ("REGULAR", "Go Sedan", "170.06", "3", "sedan_image"),
        ("REGULAR", "Go Wagon", "220.20", "4", "wagon_image"),
        ("LUXURY", "Go Minivans", "399.99", "6", "minivan_image"),
        ("LUXURY", "Go Minibus", "999.99", "10", "minibus_image")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CarCell")
        view.addSubview(tableView)
    }

    // TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // REGULAR and LUXURY
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.filter { $0.category == (section == 0 ? "REGULAR" : "LUXURY") }.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath)
        
        // Filter cars based on section (category: REGULAR or LUXURY)
        let filteredCars = cars.filter { $0.category == (indexPath.section == 0 ? "REGULAR" : "LUXURY") }
        let car = filteredCars[indexPath.row]
        
        // Customize cell appearance with car name, price, capacity, and image
        cell.textLabel?.text = "\(car.name) - \(car.price) USD"
        cell.imageView?.image = UIImage(named: car.image)
        return cell
    }
    
    // TableView Delegate (optional)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle selection (e.g., proceed with booking)
    }

    // Header for each section (REGULAR and LUXURY)
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "REGULAR" : "LUXURY"
    }
}
