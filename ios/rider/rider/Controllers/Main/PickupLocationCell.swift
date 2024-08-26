//
//  PickupLocationCell.swift
//  rider
//
//  Created by Admin on 18/07/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit

class PickupLocationCell: UITableViewCell {
    @IBOutlet weak var pickupLocationTextField: UITextField!
    //@IBOutlet weak var pickupButton: UIButton!
    var onsaveButtonTapped: (() -> Void)?

    var onPickupButtonTapped: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func savedLocationget(_ sender: Any) {
        onsaveButtonTapped?()

    }
    @IBOutlet weak var startbutton: UIButton!
    @IBAction func pickupButtonTapped(_ sender: UIButton) {
        onPickupButtonTapped?()
    }
}
