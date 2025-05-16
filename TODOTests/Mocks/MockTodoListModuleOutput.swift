//
//  MockTodoListModuleOutput.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

@testable import TODO

class MockTodoListModuleOutput: TodoListModuleInput {
    var refreshUpdatedTodoCalledWith: Todo?
    var addNewTodoCalledWith: (title: String?, body: String?)?

    func refreshUpdatedTodo(todo: Todo) {
        refreshUpdatedTodoCalledWith = todo
    }
    func addNewTodo(title: String?, body: String?) {
        addNewTodoCalledWith = (title, body)
    }
}
