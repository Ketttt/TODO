//
//  TodoDetailAssembly.swift
//  TODO
//
//  Created by Katerina Ivanova on 12.05.2025.
//

import UIKit

final class TodoDetailAssembly {
    func makeModule(todo: Todo?, output: TodoListModuleInput, isNewTodo: Bool) -> UIViewController {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let coreData = CoreDataManager(context: context)
        let interactor = TodoDetailInteractor(coreDataManager: coreData)
        let view = TodoDetailViewController()
        let router = TodoDetailRouter(view)
        let presenter = TodoDetailPresenter(interactor: interactor,
                                            router: router,
                                            view: view,
                                            todo: todo,
                                            output: output,
                                            isNewTodo: isNewTodo)
        view.presenter = presenter
        return view
    }
}
