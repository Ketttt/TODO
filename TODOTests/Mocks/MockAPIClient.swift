//
//  MockAPIClient.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

@testable import TODO

class MockAPIClient: APIClientProtocol {
    var fetchTodosCalled = false
    var fetchTodosResult: Result<TodoList, NetworkError>?

    func fetchTodos(completion: @escaping (Result<TodoList, NetworkError>) -> Void) {
        fetchTodosCalled = true
        if let result = fetchTodosResult {
            completion(result)
        }
    }
}
