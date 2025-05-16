//
//  MockTodoListInteractor.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

@testable import TODO

class MockTodoListInteractor: ITodoListInteractor {
    var fetchTodoListCalled = false
    var changeTaskStatusCalled = false
    var deleteTodoCalled = false
    var addTodoCalled = false
    var searchTodoCalled = false

    var fetchTodoListResult: Result<[Todo], AppError>?
    var changeTaskStatusResult: Result<Todo, CoreDataError>?
    var deleteTodoResult: Result<Todo, CoreDataError>?
    var addTodoResult: Result<Todo, CoreDataError>?
    var searchTodoResult: Result<[Todo], CoreDataError>?
    
    var lastAddedTodoInfo: (title: String?, body: String?)?
    var lastSearchedText: String?

    func fetchTodoList(completion: @escaping (Result<[Todo], AppError>) -> Void) {
        fetchTodoListCalled = true
        if let result = fetchTodoListResult { completion(result) }
    }
    func changeTaskStatus(for todoId: Int64, completion: @escaping (Result<Todo, CoreDataError>) -> Void) {
        changeTaskStatusCalled = true
        if let result = changeTaskStatusResult { completion(result) }
    }
    func deleteTodo(for todoId: Int64, completion: @escaping (Result<Todo, CoreDataError>) -> Void) {
        deleteTodoCalled = true
        if let result = deleteTodoResult { completion(result) }
    }
    func addTodo(title: String?, body: String?, completion: @escaping (Result<Todo, CoreDataError>) -> ()) {
        addTodoCalled = true
        lastAddedTodoInfo = (title, body)
        if let result = addTodoResult { completion(result) }
    }
    func searchTodo(with searchText: String, completion: @escaping (Result<[Todo], CoreDataError>) -> ()) {
        searchTodoCalled = true
        lastSearchedText = searchText
        if let result = searchTodoResult { completion(result) }
    }
}
