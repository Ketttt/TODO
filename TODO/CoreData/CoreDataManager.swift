//
//  CoreDataManager.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import Foundation
import CoreData


protocol CoreDataManagerProtocol: AnyObject {
    func saveTodos(_ todo: [Todo], completion: @escaping (Result<Void, CoreDataError>) -> ())
    func fetchTodoList(completion: @escaping (Result<[Todo], CoreDataError>) -> ())
    func changeTaskStatus(for todoId: Int64, completion: @escaping (Result<Todo, CoreDataError>) -> ())
    func deleteTodo(for todoId: Int64, completion: @escaping (Result<Todo, CoreDataError>) -> ())
    func addTodo(title: String?, body: String?, completion: @escaping(Result<Todo, CoreDataError>) -> ())
    func editTodo(id: Int64, title: String?, body: String?, completion: @escaping(Result<Todo, CoreDataError>) -> ())
    func searchTodo(with searchText: String, completion: @escaping(Result<[Todo], CoreDataError>) -> ())
}

final class CoreDataManager {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        context.automaticallyMergesChangesFromParent = true
    }
}

extension CoreDataManager: CoreDataManagerProtocol {
    
    func saveTodos(_ todo: [Todo], completion: @escaping(Result<Void, CoreDataError>) -> ()) {
        context.perform {
            do {
                for todo in todo {
                    let todoEntity = TodoEntity(context: self.context)
                    todoEntity.id = Int64(todo.id)
                    todoEntity.todoTitle = todo.todo
                    todoEntity.body = todo.body
                    todoEntity.completed = todo.completed
                    todoEntity.date = todo.date
                }
                try self.context.save()
                completion(.success(()))
            } catch {
                self.context.rollback()
                completion(.failure(.saveFailed(error)))
            }
        }
    }
    
    func fetchTodoList(completion: @escaping(Result<[Todo], CoreDataError>) -> ()) {
        context.perform {
            let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            do {
                let entities = try self.context.fetch(fetchRequest)
                let todos = entities.compactMap({ todo in
                    Todo(id: todo.id, todo: todo.todoTitle ?? "", completed: todo.completed, body: todo.body ?? "", date: .now)
                })
                DispatchQueue.main.async {
                    completion(.success(todos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure((.fetchFailed(error))))
                }
            }
        }
    }
    
    func changeTaskStatus(for todoId: Int64, completion: @escaping(Result<Todo, CoreDataError>) -> ()) {
        context.perform {
            let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", todoId)
            
            do {
                let todos = try self.context.fetch(fetchRequest)
                guard let todo = todos.first else {
                    completion(.failure(.objectNotFound(id: todoId)))
                    return
                }
                todo.completed.toggle()
                try self.context.save()
                DispatchQueue.main.async {
                    completion(.success(Todo(id: todo.id, todo: todo.todoTitle ?? "", completed: todo.completed, body: todo.body ?? "", date: .now)))
                }
            } catch {
                self.context.rollback()
                DispatchQueue.main.async {
                    completion(.failure(.updateFailed(error)))
                }
            }
        }
    }
    
    func deleteTodo(for todoId: Int64, completion: @escaping(Result<Todo, CoreDataError>) -> ()) {
        context.perform {
            let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %lld", todoId)
            
            do {
                guard let todoEntity = try self.context.fetch(fetchRequest).first else {
                    completion(.failure(.objectNotFound(id: todoId)))
                    return
                }
                
                let todo = Todo(
                    id: todoEntity.id,
                    todo: todoEntity.todoTitle ?? "",
                    completed: todoEntity.completed,
                    body: todoEntity.body ?? "",
                    date: todoEntity.date ?? Date()
                )
                
                self.context.delete(todoEntity)
                try self.context.save()
                
                DispatchQueue.main.async {
                    completion(.success(todo))
                }
            } catch {
                self.context.rollback()
                DispatchQueue.main.async {
                    completion(.failure(.deleteFailed(error)))
                }
            }
        }
    }
    
    func addTodo(title: String?, body: String?, completion: @escaping(Result<Todo, CoreDataError>) -> ()) {
        context.perform {
            
            let todo = TodoEntity(context: self.context)
            let newID = self.generateSafeUniqueID()
            todo.id = newID
            todo.todoTitle = title
            todo.body = body
            todo.completed = false
            todo.date = Date()
            
            do {
                try self.context.save()
                let savedTodo = Todo(
                    id: todo.id,
                    todo: todo.todoTitle ?? "",
                    completed: todo.completed,
                    body: todo.body ?? "",
                    date: todo.date ?? Date()
                )
                DispatchQueue.main.async {
                    completion(.success(savedTodo))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.addFailed(error)))
                }
            }
        }
    }
    
    func editTodo(id: Int64, title: String?, body: String?, completion: @escaping (Result<Todo, CoreDataError>) -> ()) {
        context.perform {
            let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
            
            do {
                let todos = try self.context.fetch(fetchRequest)
                guard let editTodo = todos.first else {
                    completion(.failure(.objectNotFound(id: id)))
                    return
                }
                editTodo.todoTitle = title
                editTodo.body = body
                
                try self.context.save()
                let todo = Todo(
                    id: editTodo.id,
                    todo: editTodo.todoTitle ?? "",
                    completed: editTodo.completed,
                    body: editTodo.body ?? "",
                    date: .now)
                DispatchQueue.main.async {
                    completion(.success(todo))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.updateFailed(error)))
                }
            }
        }
    }
    
    func searchTodo(with searchText: String, completion: @escaping(Result<[Todo], CoreDataError>) -> ()) {
        
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            DispatchQueue.main.async {
                completion(.success([]))
            }
            return
        }
        
        context.perform {
            
            let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
            let predicate1 = NSPredicate(format: "todoTitle CONTAINS %@", searchText)
            let predicate2 = NSPredicate(format: "body CONTAINS %@", searchText)
            
            fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
            
            do {
                let searchTodos = try self.context.fetch(fetchRequest)
                if searchText.isEmpty {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                }
                
                let todos = searchTodos.map { todo in
                    Todo(id: todo.id,
                         todo: todo.todoTitle ?? "",
                         completed: todo.completed,
                         body: todo.body)
                }
                
                let newTodos = todos.map { $0 }
                DispatchQueue.main.async {
                    completion(.success(newTodos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.searchTodoFailed))
                }
            }
        }
    }
}


private extension CoreDataManager {
    func generateSafeUniqueID() -> Int64 {
        let range: ClosedRange<Int64> = 1_000...99_999_999
        var newID: Int64
        let existingIDs = fetchAllTodoIDs()
        repeat {
            newID = Int64.random(in: range)
        } while existingIDs.contains(newID)
        return newID
    }
    
    func fetchAllTodoIDs() -> Set<Int64> {
        let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        request.propertiesToFetch = ["id"]
        
        do {
            let results = try context.fetch(request)
            return Set(results.compactMap { $0.id })
        } catch {
            return []
        }
    }
}
