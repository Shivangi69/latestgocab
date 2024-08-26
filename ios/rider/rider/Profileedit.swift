//
//  Profileedit.swift
//  rider
//
//  Created by Rohit wadhwa on 20/08/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import Foundation
import MaterialComponents
class Profileedit: UIViewController {

  
    @IBOutlet weak var Name: MDCOutlinedTextField!
    
    @IBOutlet weak var Email: MDCOutlinedTextField!
    
    @IBOutlet weak var Uploadid: MDCOutlinedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        Name.label.text = "Name*"
        Name.placeholder = "Name"
        Name.sizeToFit()
    
        Email.label.text = "Email*"
        Email.placeholder = "Email"
        Email.sizeToFit()
    
        Uploadid.label.text = "Upload ID*"
        Uploadid.placeholder = "Upload ID"
        Uploadid.sizeToFit()
        

    }
}
