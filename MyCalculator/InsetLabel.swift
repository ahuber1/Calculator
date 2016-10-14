//
//  InsetLabel.swift
//  MyCalculator
//
//  Created by Andrew Huber on 10/7/16.
//  Copyright © 2016 andrewhuber. All rights reserved.
//

import UIKit

/** 
    This is a standard UILabel except there is 12pt padding on the left, right, top, and 
    bottom
 */
class InsetLabel: UILabel {
    let topInset = CGFloat(12.0), bottomInset = CGFloat(12.0), leftInset = CGFloat(12.0), rightInset = CGFloat(12.0)
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var intrinsicSuperViewContentSize = super.intrinsicContentSize
            intrinsicSuperViewContentSize.height += topInset + bottomInset
            intrinsicSuperViewContentSize.width += leftInset + rightInset
            return intrinsicSuperViewContentSize
        }
    }
}
