//
//  UILabel+Extension.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import UIKit

extension UILabel {
    static func make(textColor: UIColor, font: UIFont, numberOfLines: Int,_ textAlignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.textColor = textColor
        label.font = font
        label.textAlignment = textAlignment
        label.numberOfLines = numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
