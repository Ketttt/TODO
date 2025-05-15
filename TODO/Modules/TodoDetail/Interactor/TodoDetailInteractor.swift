//
//  TodoDetailInteractor.swift
//  TODO
//
//  Created by Katerina Ivanova on 12.05.2025.
//

protocol ITodoDetailInteractor: AnyObject {
    func editTodo(id: Int64, title: String?, body: String?, completion: @escaping(Result<Todo, CoreDataError>) -> ())
}

final class TodoDetailInteractor {
    
    private let coreDataManager: CoreDataManagerProtocol
    
    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
    }
}

extension TodoDetailInteractor: ITodoDetailInteractor {
    
    func editTodo(id: Int64, title: String?, body: String?, completion: @escaping (Result<Todo, CoreDataError>) -> ()) {
        coreDataManager.editTodo(id: id, title: title, body: body, completion: completion)
    }
}
