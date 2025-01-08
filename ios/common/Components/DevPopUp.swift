//
//  DevPopUp.swift
//  Tendit
//
//  Created by Misha Infotech Private Limited on 25/11/17.
//  Copyright © 2017 MIPL. All rights reserved.
//

import UIKit

class DevPopUp: UIViewController {
    @IBOutlet var contentView: UIView!
    var TouchInBackground : Bool = true
    var controller = UIViewController()
    var navController = UINavigationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.4)
        
    }
    func popUpWithViewwithtouch(_view : UIView, onController : UIViewController) -> Self {
        
        let bgView = UIView.init(frame: self.view.bounds)
        bgView.backgroundColor=UIColor.clear
        self.view.addSubview(bgView);
        TouchInBackground = true
        contentView = _view
        controller = onController
        contentView.center=self.view.center
        self.view.addSubview(contentView)
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.viewTouchEvent (_:)))
        bgView.addGestureRecognizer(gesture)
        return self
    }
    
    func popUpWithView(_view : UIView, onController : UIViewController) -> Self {
        
        let bgView = UIView.init(frame: self.view.bounds)
        bgView.backgroundColor=UIColor.clear
        self.view.addSubview(bgView);
        
        TouchInBackground = false
        contentView = _view
        controller = onController
        contentView.center=self.view.center
        self.view.addSubview(contentView)
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.viewTouchEvent (_:)))
        bgView.addGestureRecognizer(gesture)
        return self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideTouchInBackground( value : Bool) {
        TouchInBackground=value
    }
    
    func show()  {
        navController = UINavigationController.init(rootViewController: self)
        navController.view.frame=self.view.frame
        controller.view.addSubview(navController.view)
        controller.addChild(navController)
        navController.didMove(toParent: controller)
        navigationController?.setNavigationBarHidden(true, animated: false)
        //self.view.layoutIfNeeded()
    }
    
    func dismiss(value : Bool)  {
        if value {
            contentView.removeFromSuperview()
            navController.view.removeFromSuperview()
            navController.removeFromParent()
        }
    }
    
    @objc func viewTouchEvent(_ sender:UITapGestureRecognizer){
        // do other task
        dismiss(value: TouchInBackground)
    }

}
