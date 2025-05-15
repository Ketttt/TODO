//
//  TodoList.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

struct TodoList: Codable {
    var todos: [Todo]
    let total, skip, limit: Int
}
