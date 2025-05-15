//
//  TodoEntity+CoreDataProperties.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//
//

import Foundation
import CoreData


extension TodoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoEntity> {
        return NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var todoTitle: String?
    @NSManaged public var completed: Bool
    @NSManaged public var body: String?
    @NSManaged public var date: Date?

}

extension TodoEntity : Identifiable {

}
