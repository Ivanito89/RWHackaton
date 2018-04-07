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

    @IBInspectable var shadowColor: UIColor = UIColor.lightGray {
        didSet {
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOpacity = 0.6
            layer.shadowRadius = 4.0
            layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        }
    }
    
}

extension RoundedView {

    func fadeIn() {
        RoundedView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: nil)
    }

    func fadeOut() {
        RoundedView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }

}

extension UILabel {

    func fadeIn() {
        UILabel.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: nil)
    }

    func fadeOut() {
        UILabel.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }

}
