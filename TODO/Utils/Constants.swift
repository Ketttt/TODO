//
//  Constants.swift
//  TODO
//
//  Created by Katerina Ivanova on 12.05.2025.
//

import Foundation

enum Constants {
    // MARK: - Paddings & Spacings
    enum Margins {
        static let trailingPadding: CGFloat = -20
        static let leadingPadding: CGFloat = 20
        
        static let topPadding: CGFloat = 16
        static let bottomPadding: CGFloat = -16
        static let topCellPadding: CGFloat = 12
        static let bottomCellPadding: CGFloat = -12
        
        static let iconToContentSpacing: CGFloat = 8
        static let interlineSpacing: CGFloat = 6
        static let titleToDateSpacing: CGFloat = 8
        static let navBackSpacing: CGFloat = 6
    }
    
    // MARK: - Sizes
    enum Sizes {
        static let checkboxSize: CGFloat = 24
        static let bottomBarHeight: CGFloat = 49
        static let titleTextHeight: CGFloat = 40
        static let noteTextHeight: CGFloat = 120
    }
    
    // MARK: - Date Formats
    enum DateFormat {
        static let dateFormat = "dd/MM/YYYY"
    }
    
    // MARK: - Appearance
    enum Appearance {
        static let cornerRadius: CGFloat = 12
    }
    
    // MARK: - Text Size
    enum Text {
        static let title: CGFloat = 34
        static let mainSize: CGFloat = 16
        static let system: CGFloat = 17
    }
}
