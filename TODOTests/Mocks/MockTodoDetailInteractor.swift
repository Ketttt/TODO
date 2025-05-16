//
//  MockTodoDetailInteractor.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

@testable import TODO

class MockTodoDetailInteractor: ITodoDetailInteractor {
    var editTodoCalled = false
    var editTodoResult: Result<Todo, CoreDataError>?
    var lastEditedTodoInfo: (id: Int64, title: String?, body: String?)?

    func editTodo(id: Int64, title: String?, body: String?, completion: @escaping (Result<Todo, CoreDataError>) -> ()) {
        editTodoCalled = true
        lastEditedTodoInfo = (id, title, body)
        if let result = editTodoResult {
            completion(result)
        }
    }
}
