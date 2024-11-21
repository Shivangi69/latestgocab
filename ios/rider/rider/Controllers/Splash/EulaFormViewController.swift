//
//  EulaFormViewController.swift
//  rider
//
//  Created by Admin on 02/09/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit

class EulaFormViewController: UIViewController {
var EulaTextStr = String()
    var mobileTextStr = String()
    @IBOutlet weak var custumescroll: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)

//      self.title = "Eula Terms".uppercased()
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationItem.backButtonTitle = ""
        
        if let backgroundImage = UIImage(named: "bggg") {
                     custumescroll.backgroundColor = UIColor(patternImage: backgroundImage)
                 }
        // Do any additional setup after loading the view.
        EulaText.text = EulaTextStr
    }
    
    @IBAction func Continue(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Enterphonenumber") as? Enterphonenumber {
            // vc.verificationID =  self.verificationID ?? ""
            //
            vc.EulaTextStr = EulaTextStr
            vc.mobileTextStr = mobileTextStr
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBOutlet weak var EulaText: UILabel!
   

}
