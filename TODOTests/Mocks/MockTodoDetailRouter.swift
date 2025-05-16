//
//  MockTodoDetailRouter.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

@testable import TODO

class MockTodoDetailRouter: ITodoDetailRouter {
    var popToToDoListCalled = false
    func popToToDoList() {
        popToToDoListCalled = true
    }
}
