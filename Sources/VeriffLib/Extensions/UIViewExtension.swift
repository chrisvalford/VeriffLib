//
//  UIViewExtension.swift
//  VeriffI
//
//  Created by Christopher Alford on 29/3/22.
//

import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
        }
    }
}
