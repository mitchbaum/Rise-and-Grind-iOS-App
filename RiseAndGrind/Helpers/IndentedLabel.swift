//
//  IndentedLabel.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/5/22.
//

import Foundation
import UIKit
// create UILabel subclass for custom text drawing - usually for my headers
class IndentedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        let customRect = rect.inset(by: insets)
        super.drawText(in: customRect)
    }
}
