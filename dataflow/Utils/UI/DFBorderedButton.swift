//
//  DFBorderedButton.swift
//  
//
//  Created by Valentin Dufois on 09/12/2018.
//

import Foundation
import UIKit

/// Represent a simple bordered button
@IBDesignable class DFBorderedButton: UIButton {

	/// Tint of the button
	@IBInspectable var tint: UIColor = UIColor.darkGray {
		didSet {
			setupAppearance()
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupAppearance()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupAppearance()
	}

	/// Sets the button's appearance
	func setupAppearance() {
		self.tintColor = tint

		self.setTitleColor(tint, for: .normal)
		self.setTitleColor(tint, for: .highlighted)

		self.titleLabel?.font = UIFont.systemFont(ofSize: 15)

		self.layer.borderColor = tint.cgColor
		self.layer.cornerRadius = 5
		self.layer.borderWidth = 1

		self.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 6, right: 15)
	}

	/// update the button style when it gets highlighted
	override var isHighlighted: Bool {
		didSet {
			if(isHighlighted) {
				self.layer.borderWidth = 0
				return
			}

			self.layer.borderWidth = 1
		}
	}

	/// Prepare the button for Interface Builder
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
	}
}
