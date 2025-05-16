//
//  MockCoreDataManager.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

@testable import TODO
import CoreData
import Foundation

class MockCoreDataManager: CoreDataManagerProtocol {
    var saveTodosCalled = false
    var fetchTodoListCalled = false
    var changeTaskStatusCalled = false
    var deleteTodoCalled = false
    var addTodoCalled = false
    var editTodoCalled = false
    var searchTodoCalled = false
    
    var saveTodosResult: Result<Void, CoreDataError>?
    var fetchTodoListResult: Result<[Todo], CoreDataError>?
    var changeTaskStatusResult: Result<Todo, CoreDataError>?
    var deleteTodoResult: Result<Todo, CoreDataError>?
    var addTodoResult: Result<Todo, CoreDataError>?
    var editTodoResult: Result<Todo, CoreDataError>?
    var searchTodoResult: Result<[Todo], CoreDataError>?
    
    var lastAddedTodo: Todo?
    var lastEditedTodo: Todo?
    var lastSearchedText: String?
    
    func saveTodos(_ todos: [Todo], completion: @escaping (Result<Void, CoreDataError>) -> ()) {
        saveTodosCalled = true
        if let result = saveTodosResult {
            completion(result)
        }
    }
    
    func fetchTodoList(completion: @escaping (Result<[Todo], CoreDataError>) -> ()) {
        fetchTodoListCalled = true
        
        if let result = fetchTodoListResult {
            completion(result)
        }
    }
    
    func changeTaskStatus(for todoId: Int64, completion: @escaping (Result<Todo, CoreDataError>) -> ()) {
        changeTaskStatusCalled = true
        if let result = changeTaskStatusResult {
            completion(result)
        }
    }
    
    func deleteTodo(for todoId: Int64, completion: @escaping (Result<Todo, CoreDataError>) -> ()) {
        deleteTodoCalled = true
        if let result = deleteTodoResult {
            completion(result)
        }
    }
    
    func addTodo(title: String?, body: String?, completion: @escaping (Result<Todo, CoreDataError>) -> ()) {
        addTodoCalled = true
        let todo = Todo(id: Int64.random(in: 1...1000), todo: title ?? "", completed: false, body: body)
        lastAddedTodo = todo
        if let result = addTodoResult {
            completion(result)
        } else {
            completion(.success(todo))
        }
    }
    
    func editTodo(id: Int64, title: String?, body: String?, completion: @escaping (Result<Todo, CoreDataError>) -> ()) {
        editTodoCalled = true
        let todo = Todo(id: id, todo: title ?? "", completed: false, body: body)
        lastEditedTodo = todo
        if let result = editTodoResult {
            completion(result)
        } else {
            completion(.success(todo))
        }
    }
    
    func searchTodo(with searchText: String, completion: @escaping (Result<[Todo], CoreDataError>) -> ()) {
        searchTodoCalled = true
        lastSearchedText = searchText
        if let result = searchTodoResult {
            completion(result)
        }
    }
}
