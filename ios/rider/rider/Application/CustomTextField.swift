//
//  CustomTextField.swift
//  rider
//
//  Created by Rohit wadhwa on 09/08/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable
class CustomTextField: UITextField {

    private var topLabel: UILabel = UILabel()
    private var isLabelFloating = false
    
    @IBInspectable var topLabelColor: UIColor = .black {
        didSet {
            topLabel.textColor = topLabelColor
        }
    }

    @IBInspectable var topLabelText: String = "" {
        didSet {
            topLabel.text = topLabelText
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.black {
        didSet {
            updateBorderColor()
        }
    }
    
    @IBInspectable var focusedBorderColor: UIColor = UIColor.blue

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        updateBorderColor()

        // Configure the top label
        topLabel.font = UIFont.systemFont(ofSize: 16.0)
        topLabel.textColor = topLabelColor
        topLabel.textAlignment = .left
        topLabel.text = topLabelText
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(topLabel)

        // Set up initial constraints for the top label
        NSLayoutConstraint.activate([
            topLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            topLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        // Add a padding to the text field
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 20))
        self.leftView = padding
        self.leftViewMode = .always

        // Add editing events
        self.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        self.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateBorderColor()
        updateLabelPosition(animated: false)
    }

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            self.layer.borderColor = focusedBorderColor.cgColor
        }
        return result
    }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            updateBorderColor()
        }
        return result
    }

    @objc private func textFieldDidBeginEditing() {
        updateLabelPosition(animated: true)
    }

    @objc private func textFieldDidEndEditing() {
        updateLabelPosition(animated: true)
    }

    @objc private func textFieldDidChange() {
        updateLabelPosition(animated: true)
    }

    private func updateLabelPosition(animated: Bool) {
        let shouldFloat = self.text?.isEmpty == false || self.isFirstResponder
        
        if shouldFloat && !isLabelFloating {
            isLabelFloating = true
            let topLabelNewConstraints = [
                topLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                topLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -2)
            ]
            moveLabel(to: topLabelNewConstraints, fontSize: 12.0, animated: animated)
        } else if !shouldFloat && isLabelFloating {
            isLabelFloating = false
            let topLabelOriginalConstraints = [
                topLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                topLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ]
            moveLabel(to: topLabelOriginalConstraints, fontSize: 16.0, animated: animated)
        }
    }
    
    private func moveLabel(to constraints: [NSLayoutConstraint], fontSize: CGFloat, animated: Bool) {
        NSLayoutConstraint.deactivate(topLabel.constraints)
        NSLayoutConstraint.activate(constraints)
        
        let changeFont = { self.topLabel.font = UIFont.systemFont(ofSize: fontSize) }
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
                changeFont()
            }
        } else {
            changeFont()
            self.layoutIfNeeded()
        }
    }

    private func updateBorderColor() {
        self.layer.borderColor = borderColor.cgColor
        topLabel.textColor = topLabelColor
    }
}
