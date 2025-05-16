//
//  MockTodoDetailView.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

@testable import TODO

class MockTodoDetailView: ITodoDetailView {
    var showErrorCalled = false
    var errorTitle: String?
    var errorMessage: String?

    func showError(title: String, message: String) {
        showErrorCalled = true
        errorTitle = title
        errorMessage = message
    }
}
