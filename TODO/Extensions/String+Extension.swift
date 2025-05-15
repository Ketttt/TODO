//
//  String+Extension.swift
//  TODO
//
//  Created by Katerina Ivanova on 12.05.2025.
//

extension String {
    var nilIfEmpty: String? {
        return isEmpty ? nil : self
    }
}
