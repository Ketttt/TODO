//
//  MockTodoListRouter.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

@testable import TODO

class MockTodoListRouter: ITodoListRouter {
    var openTodoDetailCalled = false
    var openTodoDetailTodo: Todo?
    var openTodoDetailIsNewTodo: Bool?

    func openTodoDetail(todo: Todo?, output: TodoListModuleInput, isNewTodo: Bool) {
        openTodoDetailCalled = true
        openTodoDetailTodo = todo
        openTodoDetailIsNewTodo = isNewTodo
    }
}
