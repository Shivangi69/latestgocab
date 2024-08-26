//
//  welcomeScreen.swift
//  rider
//
//  Created by Rohit wadhwa on 23/08/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit

class welcomeScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func Proceedbtn(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController {
           
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
  

}
