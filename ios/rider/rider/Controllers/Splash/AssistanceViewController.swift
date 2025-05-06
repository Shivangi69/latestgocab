//  AssistanceViewController.swift
//  rider

import UIKit
import Kingfisher
import MessageKit

class AssistanceViewController: UIViewController {
    let user = try! Rider(from: UserDefaultsConfig.user!)

    override func viewDidLoad() {
        super.viewDidLoad()
        profileimg.layer.cornerRadius = self.profileimg.frame.size.width/2
        profileimg.layer.masksToBounds = true
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.title = "Need Assistance".uppercased()
        if let riderImage = user.media?.address {
            let processor = DownsamplingImageProcessor(size: profileimg.intrinsicContentSize) |> RoundCornerImageProcessor(cornerRadius: profileimg.intrinsicContentSize.width / 2)
            let url = URL(string: Config.Backend + riderImage.replacingOccurrences(of: " ", with: "%20"))
            
            profileimg.kf.setImage(with: url, placeholder: UIImage(named: "Nobody"), options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage
            ], completionHandler: { result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            })
        }
        if let mobileNumber = user.mobileNumber {
            phonenumlbl.text = String(mobileNumber)
        }
    }

    
    @IBOutlet weak var profileimg: UIImageView!
    
    @IBOutlet weak var phonenumlbl: UILabel!
    
    @IBAction func GoChat(_ sender: Any) {
        let vc = ChatWithAdminViewController()
        vc.sender = Admin()
        self.navigationController!.pushViewController(vc, animated: true)
    }
   @IBAction func CloseAction(_ sender: Any) {
       navigationController?.popViewController(animated: true)
    }
    
   

}
