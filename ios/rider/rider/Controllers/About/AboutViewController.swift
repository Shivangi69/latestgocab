//
//  AboutViewController.swift
//  Rider
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

import UIKit
import Eureka

class AboutViewController: UIViewController {
    @IBOutlet weak var versingsting: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        form +++ Section(header: NSLocalizedString("Info", comment: ""), footer: NSLocalizedString("© 2020 Minimalistic Apps All rights reserved.", comment: ""))
//            <<< LabelRow(){
//                $0.title = NSLocalizedString("Application Name", comment: "")
//                $0.value = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
//            }
//            <<< LabelRow(){
//                $0.title = NSLocalizedString("Version", comment: "")
//                $0.value = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
//            }
//            <<< LabelRow(){
//                $0.title = NSLocalizedString("Website", comment: "")
//                $0.value = "http://www.ridy.io"
//            }
//            <<< LabelRow(){
//                $0.title = NSLocalizedString("Phone Number", comment: "")
//                $0.value = "-"
//        }
        
        
        // Fetch the app version from Info.plist
          if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
              let versionString = appVersion
              
              // Set the UILabel's text
              versingsting.text = versionString
              print(versionString) // Debugging
          }

        
        
        
    }
}
