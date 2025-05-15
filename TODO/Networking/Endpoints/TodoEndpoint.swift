//
//  TodoEndpoint.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import Foundation

enum TodoEndpoint: EndpointProtocol {
    case fetchTodos
    
    var path: String {
        switch self {
        case .fetchTodos: "/todos"
        }
    }
    
    var method: String {
        switch self {
        case .fetchTodos: return "GET"
        }
    }
    
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    var body: Data? {
        switch self {
        case.fetchTodos:
            return nil
        }
    }
}
