//
//  Todo.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import Foundation

struct Todo: Codable {
    let id: Int64
    let todo: String
    let completed: Bool
    var body: String?
    var date: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    
    enum CodingKeys: String, CodingKey {
        case id, todo, completed
    }
}
