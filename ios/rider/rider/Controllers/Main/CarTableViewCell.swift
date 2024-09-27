//
//  CarTableViewCell.swift
//  rider
//
//  Created by Admin on 27/09/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit

class CarTableViewCell: UITableViewCell {
    
    let carImageView = UIImageView()
    let carNameLabel = UILabel()
    let carPriceLabel = UILabel()
    let carCapacityLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        carImageView.translatesAutoresizingMaskIntoConstraints = false
        carNameLabel.translatesAutoresizingMaskIntoConstraints = false
        carPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        carCapacityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(carImageView)
        contentView.addSubview(carNameLabel)
        contentView.addSubview(carPriceLabel)
        contentView.addSubview(carCapacityLabel)
        
        // Add constraints here for positioning the elements
        NSLayoutConstraint.activate([
            carImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            carImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            carImageView.widthAnchor.constraint(equalToConstant: 60),
            carImageView.heightAnchor.constraint(equalToConstant: 60),
            
            carNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            carNameLabel.leadingAnchor.constraint(equalTo: carImageView.trailingAnchor, constant: 16),
            
            carPriceLabel.topAnchor.constraint(equalTo: carNameLabel.bottomAnchor, constant: 8),
            carPriceLabel.leadingAnchor.constraint(equalTo: carImageView.trailingAnchor, constant: 16),
            
            carCapacityLabel.topAnchor.constraint(equalTo: carPriceLabel.bottomAnchor, constant: 8),
            carCapacityLabel.leadingAnchor.constraint(equalTo: carImageView.trailingAnchor, constant: 16),
            carCapacityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with car: (name: String, price: String, capacity: String, image: String)) {
        carImageView.image = UIImage(named: car.image)
        carNameLabel.text = car.name
        carPriceLabel.text = "\(car.price) USD"
        carCapacityLabel.text = "Capacity: \(car.capacity)"
    }
}
