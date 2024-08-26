//
//  DropLocationCell.swift
//  rider
//
//  Created by Admin on 18/07/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit

class DropLocationCell: UITableViewCell {
    @IBOutlet weak var dropLocationTextField: UITextField!
//    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var micbutton: UIButton!
    var onAddButtonTapped: (() -> Void)?
    var onsaveButtonTapped: (() -> Void)?

    var onDeleteButtonTapped: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
//        addButton.setTitle("", for: .normal)
        deleteButton.setTitle("", for: .normal)
        micbutton.setTitle("", for: .normal)
        // Initialization code
    }
    @IBAction func DoneButtonCall(_ sender: Any) {
        
    }
    
    @IBAction func savedLocationget(_ sender: Any) {
        onsaveButtonTapped?()

    }
    
    @IBAction func micbuttonAction(_ sender: Any) {
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func addButtonTapped(_ sender: UIButton) {
        onAddButtonTapped?()
    }
    
    @IBAction func favouriteButtonCall(_ sender: Any) {
    }
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        onDeleteButtonTapped?()
    }
}
