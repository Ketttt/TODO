//
//  UIView+Extension.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            self.addSubview(view)
        }
    }
}
