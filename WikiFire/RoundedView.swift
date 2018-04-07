//
//  RoundedView.swift
//  WikiFire
//
//  Created by Ivan Hjelmeland on 06/04/2018.
//  Copyright © 2018 Shortcut. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {

    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var cornerRadius: Float = 0.0 {
        didSet {
            layer.cornerRadius = CGFloat(cornerRadius)
            self.clipsToBounds = false
        }
    }

    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOpacity = 0.6
            layer.shadowRadius = 4.0
            layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        }
    }
    
}
