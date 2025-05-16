//
//  MockNetworkService.swift
//  TODO
//
//  Created by Katerina Ivanova on 15.05.2025.
//

import Foundation
import XCTest
@testable import TODO

class MockNetworkService: NetworkServiceProtocol {
    var requestCalled = false
    var lastEndpoint: EndpointProtocol?
    var requestResult: Result<TodoList, NetworkError> = .failure(.noInternetConnection)
    
    func request<T: Decodable>(endpoint: EndpointProtocol, completion: @escaping (Result<T, NetworkError>) -> Void) {
        requestCalled = true
        lastEndpoint = endpoint
        
        if let result = requestResult as? Result<T, NetworkError> {
            DispatchQueue.main.async {
                completion(result)
            }
        } else {
            XCTFail("Type mismatch in mock request")
        }
    }
}
