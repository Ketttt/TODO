//
//  TodoListInteractor.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import Foundation

protocol ITodoListInteractor: AnyObject {
    func fetchTodoList(completion: @escaping (Result<[Todo], AppError>) -> Void)
    func changeTaskStatus(for todoId: Int64, completion: @escaping (Result<Todo, CoreDataError>) -> Void)
    func deleteTodo(for todoId: Int64, completion: @escaping (Result<Todo, CoreDataError>) -> Void)
    func addTodo(title: String?, body: String?, completion: @escaping(Result<Todo, CoreDataError>) -> ())
    func searchTodo(with searchText: String, completion: @escaping(Result<[Todo], CoreDataError>) -> ())
}

final class TodoListInteractor {
    
    private let apiClient: APIClientProtocol
    private let coreDataManager: CoreDataManagerProtocol
    
    init(apiClient: APIClientProtocol = APIClient(), coreDataManager: CoreDataManagerProtocol) {
        self.apiClient = apiClient
        self.coreDataManager = coreDataManager
    }
}

extension TodoListInteractor: ITodoListInteractor {
    
    func fetchTodoList(completion: @escaping (Result<[Todo], AppError>) -> Void) {
        let hasInternet = NetworkMonitor.shared.hasInternetConnection()
        let isFirstLaunch = UserDefaults.standard.isFirstLaunch

        if hasInternet && isFirstLaunch {
            self.fetchFromNetwork { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        UserDefaults.standard.isFirstLaunch = false
                        completion(result)
                    case .failure:
                        self.fetchFromCoreData(completion: completion)
                    }
                }
            }
        } else {
            self.fetchFromCoreData(completion: completion)
        }
    }
    
    func changeTaskStatus(for todoId: Int64, completion: @escaping (Result<Todo, CoreDataError>) -> Void) {
        coreDataManager.changeTaskStatus(for: todoId, completion: completion)
    }
    
    func deleteTodo(for todoId: Int64, completion: @escaping (Result<Todo, CoreDataError>) -> Void) {
        coreDataManager.deleteTodo(for: todoId, completion: completion)
    }
    
    func addTodo(title: String?, body: String?, completion: @escaping (Result<Todo, CoreDataError>) -> ()) {
        coreDataManager.addTodo(title: title, body: body, completion: completion)
    }
    
    func searchTodo(with searchText: String, completion: @escaping (Result<[Todo], CoreDataError>) -> ()) {
        coreDataManager.searchTodo(with: searchText, completion: completion)
    }
}

//MARK: - Private Methods
private extension TodoListInteractor {
    func saveToCoreData(_ todos: [Todo], completion: @escaping (Result<(Void), CoreDataError>) -> ()) {
        coreDataManager.saveTodos(todos, completion: completion)
    }
    
    func fetchFromCoreData(completion: @escaping (Result<[Todo], AppError>) -> Void) {
        coreDataManager.fetchTodoList() { result in
            switch result {
            case .success(let todoList):
                completion(.success(todoList))
            case .failure(let error):
                completion(.failure(.coreData(error)))
            }
        }
    }
    
    func fetchFromNetwork(completion: @escaping (Result<[Todo], AppError>) -> ()) {
        apiClient.fetchTodos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let todoList):
                    self?.saveToCoreData(todoList.todos) { _ in
                        self?.fetchFromCoreData(completion: completion)
                        completion(.success(todoList.todos))
                    }
                case .failure(let error):
                    completion(.failure(.network(error)))
                }
            }
        }
    }
}
