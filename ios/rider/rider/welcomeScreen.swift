//
//  welcomeScreen.swift
//  rider
//
//  Created by Rohit wadhwa on 23/08/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit

class welcomeScreen: UIViewController {
    @IBOutlet weak var custumescroll: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let backgroundImage = UIImage(named: "bggg") {
               custumescroll.backgroundColor = UIColor(patternImage: backgroundImage)
           }
    }

    @IBAction func Proceedbtn(_ sender: UIButton) {
        UserDefaults.standard.set("yes", forKey: "VeryFirsttyme")

        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController {
           
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
  

}
