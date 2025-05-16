//
//  ExtensionsTests.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

import XCTest
@testable import TODO

class ExtensionsTests: XCTestCase {

    // MARK: - Date+Extension Tests
    func testDateGetFormattedDate_returnsCorrectString() {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2025, month: 5, day: 8)
        guard let date = calendar.date(from: components) else {
            XCTFail("Could not create date from components")
            return
        }
        
        let formattedString = date.getFormattedDate(format: "dd/MM/yyyy")
        XCTAssertEqual(formattedString, "08/05/2025")
    }

    // MARK: - String+Extension Tests
    func testStringNilIfEmpty_withEmptyString_returnsNil() {
        let emptyString = ""
        XCTAssertNil(emptyString.nilIfEmpty)
    }

    func testStringNilIfEmpty_withWhitespaceString_returnsString() {
        let whitespaceString = "   "
        XCTAssertEqual(whitespaceString.nilIfEmpty, "   ")
    }

    func testStringNilIfEmpty_withNonEmptyString_returnsString() {
        let nonEmptyString = "Hello"
        XCTAssertEqual(nonEmptyString.nilIfEmpty, "Hello")
    }
}
