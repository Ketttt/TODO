//
//  TodoListAssembly.swift
//  TODO
//
//  Created by Katerina Ivanova on 08.05.2025.
//

import UIKit
import Foundation

protocol TodoListModuleInput: AnyObject {
    func refreshUpdatedTodo(todo: Todo)
    func addNewTodo(title: String?, body: String?)
}

final class TodoListAssembly {
    func makeModule() -> UIViewController {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let coreData = CoreDataManager(context: context)
        let interactor = TodoListInteractor(coreDataManager: coreData)
        let view = TodoListViewController()
        let router = TodoListRouter(view)
        let presenter = TodoListPresenter(interactor: interactor, router: router, view: view)
        view.presenter = presenter
        return view
    }
}
