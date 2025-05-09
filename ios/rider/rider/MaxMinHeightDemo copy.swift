//
//  IntrinsicDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 7/30/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit

class MaxMinHeightDemo: SimpleDemo {
    override class var name: String { "Max Min Height" }
    
    override class func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil
        
        let controller = BTTTTTTTViewController()
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.fixed(350), .fixed(650)],
            options: SheetOptions(useInlineMode: useInlineMode))
        sheet.allowPullingPastMaxHeight = false
        sheet.allowPullingPastMinHeight = false
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
