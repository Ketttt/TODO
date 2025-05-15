//
//  Date+Extenssion.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import Foundation

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
