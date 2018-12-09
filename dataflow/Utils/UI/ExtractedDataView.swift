//
//  ExtractedDataView.swift
//  dataflow
//
//  Created by Dev on 2018-12-08.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class ExtractedDataView: UIView {
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
}
