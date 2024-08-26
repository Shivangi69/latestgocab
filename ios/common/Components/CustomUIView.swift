////
////  CustomUIView.swift
////  rider
////
////  Created by Rohit wadhwa on 20/06/24.
////  Copyright © 2024 minimal. All rights reserved.
////
//
import Foundation
import UIKit

//@IBDesignable
//class CustomUIView: UIView {
//
//    // Border color
//    @IBInspectable var borderColor: UIColor? {
//        didSet {
//            self.layer.borderColor = borderColor?.cgColor
//        }
//    }
//
//    // Border width
//    @IBInspectable var borderWidth: CGFloat = 0 {
//        didSet {
//            self.layer.borderWidth = borderWidth
//        }
//    }
//
//    // Corner radius
//    @IBInspectable var cornerRadius: CGFloat = 0 {
//        didSet {
//            self.layer.cornerRadius = cornerRadius
//            self.layer.masksToBounds = cornerRadius > 0
//        }
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//
//    private func setupView() {
//        // Initialize the view with default values or custom setup
//    }
//
//    override func prepareForInterfaceBuilder() {
//        super.prepareForInterfaceBuilder()
//        setupView()
//    }
//}

@IBDesignable
class CustomUIView: UIView {

    // Border color
    @IBInspectable var borderColor: UIColor? {
        didSet {
            self.layer.borderColor = borderColor?.cgColor
        }
    }

    // Border width
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    // Corner radius
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = cornerRadius > 0
        }
    }

    // Shadow color
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            self.layer.shadowColor = shadowColor?.cgColor
        }
    }

    // Shadow opacity
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }

    // Shadow offset
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.layer.shadowOffset = shadowOffset
        }
    }

    // Shadow radius
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            self.layer.shadowRadius = shadowRadius
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // Initialize the view with default values or custom setup
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
}
