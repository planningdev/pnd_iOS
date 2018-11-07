//
//  UITextField+Extension.swift
//  P&D_App
//
//  Created by Azuma on 2018/11/06.
//  Copyright © 2018 P&D. All rights reserved.
//

import UIKit

extension UITextField {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable
    var borderWidth: CGFloat {
    get {
        return self.layer.borderWidth
    }
    set {
        self.layer.borderWidth = newValue
    }
    }

    @IBInspectable
    var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
}
