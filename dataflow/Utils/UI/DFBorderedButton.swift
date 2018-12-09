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

	func setupAppearance() {
		self.tintColor = tint

		self.setTitleColor(tint, for: .normal)
		self.setTitleColor(tint, for: .highlighted)

		self.titleLabel?.font = UIFont.systemFont(ofSize: 15)

		self.setBackgroundImage(UIImage(named: "BorderButtonTemplate"), for: .normal)
		self.setBackgroundImage(UIImage(named: "PlainButtonTemplate"), for: .highlighted)

		self.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 6, right: 15)
	}

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
	}
}
