//
//  APIClient.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import Foundation

protocol APIClientProtocol: AnyObject {
    func fetchTodos(completion: @escaping (Result<TodoList, NetworkError>) -> Void)
}

final class APIClient: APIClientProtocol {
    
    private let networkService: NetworkServiceProtocol
    private let networkMonitor = NetworkMonitor.shared
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchTodos(completion: @escaping (Result<TodoList, NetworkError>) -> Void) {
        guard networkMonitor.hasInternetConnection() else {
            completion(.failure(NetworkError.noInternetConnection))
            return
        }
        networkService.request(endpoint: TodoEndpoint.fetchTodos, completion: completion)
    }
}
