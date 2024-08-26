//
//  UnderReview.swift
//  rider
//
//  Created by Rohit wadhwa on 20/08/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

class UnderReview: UIViewController {

  
    @IBOutlet weak var baseText: MDCOutlinedTextField!
   
    @IBOutlet weak var cntry: MDCOutlinedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cntry.label.text = " number "
        cntry.placeholder = "555-"
        cntry.sizeToFit()
    
        
        baseText.label.text = "Phone number "
        baseText.placeholder = "555-555-5555 baseText"
        baseText.sizeToFit()
        

    }
}
