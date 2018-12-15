//
//  ExtractedDataView.swift
//  dataflow
//
//  Created by Dev on 2018-12-08.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import UIKit

/// Represent a extracted data view, used for styling
@IBDesignable class DFExtractedDataView: UIView {
	/// The view borders width
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    /// The views borders color
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    /// The views borders radius
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

	/// Prepare the button for Interface Builder
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
}
