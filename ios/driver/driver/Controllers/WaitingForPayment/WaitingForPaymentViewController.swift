//
//  WaitingForPaymentViewController.swift
//  driver
//
//  Created by Manly Man on 1/1/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import UIKit
import Lottie

class WaitingForPaymentViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var viewLoading: UIView!
    
    @IBOutlet weak var buttonCash: UIButton!
    
    @IBOutlet weak var AmountLable: UILabel!
    public var travel: Request = Request.shared

    @IBOutlet weak var buttonPaymnetNotReceived: UIButton!
    var animationView: LottieAnimationView!
    var onDone: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector:#selector(self.onPaid), name: .paid, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.requestRefresh), name: .connectedAfterForeground, object: nil)
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.backgroundView.addSubview(blurEffectView)
        animationView = LottieAnimationView(name: "cash")
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.loopMode = .loop
        animationView.backgroundColor = UIColor.clear
        animationView.play()
        viewLoading.addSubview(animationView)
        requestRefresh()
        NotificationCenter.default.addObserver(self, selector:#selector(self.requestRefresh), name: .connectedAfterForeground, object: nil)

        
        
        
    }
    
    @objc private func onPaid() {
        LoadingOverlay.shared.hideOverlayView()
        self.onDone?(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCashPaidTouched(_ sender: Any) {
        LoadingOverlay.shared.showOverlay(view: self.view)
        PaidInCash().execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(_):
                self.onDone?(true)
                self.dismiss(animated: true, completion: nil)
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
   
    @IBAction func notreceive(_ sender: Any) {
        LoadingOverlay.shared.showOverlay(view: self.view)
        DriverMarkedPaymentNotReceived().execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(_):
                self.onDone?(true)
                self.dismiss(animated: true, completion: nil)
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
    
    @objc private func requestRefresh() {
        animationView.play()
        self.buttonCash.isEnabled = false
        LoadingOverlay.shared.showOverlay(view: self.view)
        GetCurrentRequestInfo().execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(let response):
                self.buttonCash.isEnabled = true
                Request.shared = response.request
                self.AmountLable.text = MyLocale.formattedCurrency(amount: Request.shared.costAfterVAT!, currency: Request.shared.currency!)
            case .failure(_):
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
